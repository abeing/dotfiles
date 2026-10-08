;;; early-init.el -- Adam Miezianko's early Emacs initialization

;; Temporarily prevent garbage collection during startup.  Save the original
;; gc-cons-threshold here, to be restored at the end of `init.el'
(setq am/initial-gc-cons-threshold gc-cons-threshold)
(setq gc-cons-threshold 10000000)
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq native-comp-async-report-warnings-errors 'silent)

(setq frame-resize-pixelwise t)
(tool-bar-mode -1)
(setq default-frame-alist '((fullscreen . maximized)
                            (background-color . "#FFFFFF")
                            (vertical-scroll-bars . nil)
                            (horizontal-scroll-bars . nil)
                            (ns-appearance . light)
                            (ns-transparent-titlebar . t)))
