;;;
;;; Copyright (c) 2016, Gayane Kazhoyan <kazhoyan@cs.uni-bremen.de>
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

(in-package :donkey)

(def-fact-group donkey-motions (desig:motion-desig)

  (<- (motion-desig ?motion-designator (drive ?pose))
    (or (desig-prop ?motion-designator (:type :driving))
        (desig-prop ?motion-designator (:to :drive)))
    (or (and (desig-prop ?motion-designator (:to ?location))
             (not (equal ?location :drive)))
        (desig-prop ?motion-designator (:destination ?location)))
    (location-pose ?location ?pose))

  (<- (motion-desig ?motion-designator (mount ?robot-name T))
    (or (desig-prop ?motion-designator (:type :mounting))
        (desig-prop ?motion-designator (:to :mount)))
    (desig-prop ?motion-designator (:agent ?robot-name)))

  (<- (motion-desig ?motion-designator (mount ?robot-name NIL))
    (or (desig-prop ?motion-designator (:type :unmounting))
        (desig-prop ?motion-designator (:to :unmount)))
    (desig-prop ?motion-designator (:agent ?robot-name))))


(def-fact-group donkey-actions (action-desig)

  (<- (action-desig ?action-designator (mount ?robot-name T))
    (or (desig-prop ?action-designator (:type :mounting))
        (desig-prop ?action-designator (:to :mount)))
    (desig-prop ?action-designator (:agent ?robot-name)))

  (<- (action-desig ?action-designator (mount ?robot-name NIL))
    (or (desig-prop ?action-designator (:type :unmounting))
        (desig-prop ?action-designator (:to :unmount)))
    (desig-prop ?action-designator (:agent ?robot-name)))

  (<- (action-desig ?action-designator (navigate ?pose))
    (or (desig-prop ?action-designator (:type :going))
        (desig-prop ?action-designator (:to :go)))
    (or (desig-prop ?action-designator (:destination ?location))
        (and (desig-prop ?action-designator (:to ?location))
             (not (equal ?location :go))))
    (location-pose ?location ?pose)))
