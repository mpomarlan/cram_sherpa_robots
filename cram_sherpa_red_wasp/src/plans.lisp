;;;
;;; Copyright (c) 2017, Gayane Kazhoyan <kazhoyan@cs.uni-bremen.de>
;;; All rights reserved.
;;;
;;; Redistribution and use in source and binary forms, with or without
;;; modification, are permitted provided that the following conditions are met:
;;;
;;;     * Redistributions of source code must retain the above copyright
;;;       notice, this list of conditions and the following disclaimer.
;;;     * Redistributions in binary form must reproduce the above copyright
;;;       notice, this list of conditions and the following disclaimer in the
;;;       documentation and/or other materials provided with the distribution.
;;;     * Neither the name of the Institute for Artificial Intelligence/
;;;       Universitaet Bremen nor the names of its contributors may be used to
;;;       endorse or promote products derived from this software without
;;;       specific prior written permission.
;;;
;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;; POSSIBILITY OF SUCH DAMAGE.

(in-package :red-wasp)

(defparameter *beacon-distance-threashold* 25.0 "in meters when to consider found.")

(defmethod main ()
  (cpm:with-process-modules-running
      (red-wasp-sensors helicopter:helicopter-actuators)
    (run-reference-server "red_wasp")
    (run-perform-server "red_wasp")
    (roslisp:spin-until nil 100)))

(defun beacon-search (?object ?area &optional (velocity-gain 5.0))
  (format t "beacon search for ~a at ~a~%" ?object ?area)
  ;; turn beacon on
  (perform (desig:a motion (to switch) (device beacon) (state on)))
  (perform (desig:an action (to take-off)))
  ;; scan area until beacon starts publishing
  (cpl:pursue
    (cpl:wait-for *beacon-msg-fluent*)
    (perform (desig:an action (to scan) (area ?area))))
  ;; fly towards signal
  (let ((reached-fluent (cpl:<
                         (cpl:fl-funcall #'(lambda (beacon-msg)
                                             (roslisp:msg-slot-value
                                              beacon-msg 'sherpa_msgs-msg:beacon_value))
                                         *beacon-msg-fluent*)
                         *beacon-distance-threashold*)))
    (cpl:pursue
      (cpl:wait-for reached-fluent)
      (loop
        (when (cpl:value *beacon-msg-fluent*)
          (let* ((beacon-transform (cl-transforms-stamped:lookup-transform
                                    cram-tf:*transformer*
                                    cram-tf:*fixed-frame*
                                    "red_wasp/base_link"
                                    :time 0.0
                                    :timeout cram-tf:*tf-default-timeout*))
                 (?goal-pose (cl-transforms:make-pose
                              (cl-transforms:v+ (cl-transforms:translation beacon-transform)
                                                (cl-transforms:v*
                                                 (roslisp:with-fields (x y z)
                                                     (roslisp:msg-slot-value
                                                      (cpl:value *beacon-msg-fluent*)
                                                      'sherpa_msgs-msg:direction)
                                                   (cl-transforms:make-3d-vector x y z))
                                                 velocity-gain))
                              (cl-transforms:make-identity-rotation))))
            (call-fly-action :action-goal (cram-sherpa-robots-common:make-move-to-goal ?goal-pose))
            ;; (perform (desig:a motion (to fly) (to ?goal-pose)))
            ))))
    (helicopter:say (format nil "Red Wasp FOUND ~a." ?object))))

