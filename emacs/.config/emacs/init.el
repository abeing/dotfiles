;;; init.el --- Adam Miezianko's Emacs configuraiton

;; Author: Adam Miezianko <adam.miezianko@gmail.com>

;; This file is not part of GNU Emacs

;;; Commentary:

;; I keep removing configuration from my init.el as Emacs gets more and more
;; sane defaults.

;;; Code:

;; Just in case I run my config on an older Emacs somewhere
(when (< emacs-major-version 30)
  (error "Emacs version 30 and newer required; this is version %s" emacs-major-version))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;; --------------------[ User information ]------------------------------------

(setq user-full-name "Adam Miezianko"
      user-mail-address "adam.miezianko@gmail.com")
(setq calendar-latitude 47.6062
      calendar-longitude -122.3321)

;; Is Emacs running on my laptop? Used for setting laptop-specific settings
;; where necessary.
(defconst my-laptop-p (eq system-type 'darwin))
(defconst my-work-machine-p (eq system-type 'windows-nt))

;;; --------------------[ Computer specific settings ]--------------------------

(when my-laptop-p
  (setq ispell-program-name "/usr/local/bin/ispell")
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'none))

;; Make right-click do something sensible when using GUI Emacs
(when (display-graphic-p)
  (context-menu-mode))

;;; --------------------[ General settings ]------------------------------------

(setq-default
 inhibit-startup-screen t
 initial-scratch-message nil ; The *scratch* buffer doesn't need to comment on top
 indent-tabs-mode nil        ; Don't use tabs, ever!
 tab-width 2                 ; The number of spaces a tab is equal to
 fill-column 78              ; Wrap at 78; 72 was too narrow
 column-number-mode t        ; Display column number in the mode line
 vc-follow-symlinks t        ; Follow symlinks without asking
 ring-bell-function nil)     ; Don't ding

;; Save history of the minibuffer
(savehist-mode t)

;; Use Ctrl-<arrow keys> to move through windows
(windmove-default-keybindings 'control)

(show-paren-mode)             ; Highlight matching parenthesis
(save-place-mode)             ; Remember the point position for each file
(delete-selection-mode)       ; Replace selection when typing
(prefer-coding-system 'utf-8) ; Default to UTF-8 encoding
(electric-pair-mode nil)      ; When entering a character with a natural pair,
                              ; DON't insert it's corresponding pair

;; Don't use compiled code if its older than uncompiled code
(setq-default load-prefer-newer t)

;; Don't put 'customize' config in init.el; give it another file
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

;; Don't litter backup files everywhere. Contain them to a directory in .config
(defun am/backup-file-name (fpath)
  "Redirect the file path to backup directory where the init file lives."
  (let* ((backup-root-dir (concat user-emacs-directory "backup/"))
         (file-path (replace-regexp-in-string "[A-Za-z]:" "" fpath))
         (backup-file-path (replace-regexp-in-string "//" "/" (concat backup-root-dir file-path "~"))))
    (make-directory (file-name-directory backup-file-path) (file-name-directory backup-file-path))
    backup-file-path))
(setopt make-backup-file-name-function 'am/backup-file-name)

;;; --------------------[ Interface enhancements ]------------------------------

;; Show line and column number in the modeline
(setopt line-number-mode t)
(setopt column-number-mode t)
(setopt indicate-buffer-boundaries 'left)  ; Show buffer top and bottom in the margin

;; Change yes/no questions to y/n instead
(defalias 'yes-or-no-p 'y-or-n-p)

;; Delete trailing whitespace before saving a file
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Enable narrowing commands (C-x n)
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)

;; Enable goal column (C-x C-n)
(put 'set-goal-column 'disabled nil)

;; Automatically update buffers if file content on disk has changes
(setopt auto-revert-avoid-polling t)
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode t)

;; Don't show the menu bar, except on macOS. On macOS the menu bar doesn't take
;; up any additional screen real estate, so there's no harm in keeping it.
(when (not my-laptop-p)
  (menu-bar-mode -1))

(setq visible-bell t)

(set-face-attribute 'default nil :family "Iosevka" :height 120)
;; (set-face-attribute 'default nil :family "Go Mono" :height 100)

(setq shr-width 80)

;; I usually seperate my sentences with one space not two, but am
;; experimenting with being a two-spacer.
(setq-default sentence-end-double-space t)

(setq shift-select-mode nil)

;; Emacs doesn't provide enough terminal support for pagers like less, but we
;; don't need pagers since we have a buffer. We can just use cat instead.
(setenv "PAGER" "/bin/cat")

;; rebinding M-i (tab-to-tab-stop) to something I use more often: imenu
(global-set-key (kbd "M-i") 'imenu)
(global-set-key (kbd "C-c s i") 'imenu)

;;; --------------------[ Themes ]----------------------------------------------

(use-package modus-themes
  :ensure t
  :init
  (setq modus-themes-disable-other-themes t
        modus-themes-mode-line '(borderless accented)
        modus-themes-org-blocks 'gray-background
        modus-themes-to-toggle '(modus-operandi modus-vivendi)
        modus-themes-italic-constructs t
        modus-themes-bold-constructs t)
  (load-theme 'modus-operandi)
  :bind ("<f5>" . modus-themes-toggle))

(use-package ef-themes
  :ensure t)

;;; --------------------[ Diminish ]--------------------------------------------

(use-package diminish
  :ensure t)

;;; --------------------[ Discovery aids ]--------------------------------------

(use-package which-key
  :ensure t
  :diminish
  :config
  (which-key-mode))

;;; --------------------[ Completion ]------------------------------------------

(setopt enable-recursive-minibuffers t) ; Use the minibuffer whilst in the
                                        ; minibuffer
(setopt completion-cycle-threshold 1)   ; TAB cycles candidates
(setopt completions-detailed t)         ; Show annotations
(setopt tab-always-indent 'complete)    ; TAB tries to complete, otherwise
                                        ; indents
;; Different styles to match input candidates
(setopt completion-styles '(basic initials substring))
(setopt completion-auto-help 'always)   ; Open completion always; `lazy'
                                        ; another option
(setopt completions-max-height 20)
(setopt completions-format 'one-column)
(setopt completions-group t)
(setopt completion-auto-select 'second-tab)

;; TAB acts more like how it does in the shell
(keymap-set minibuffer-mode-map "TAB" 'minibuffer-complete)

(use-package vertico
  :ensure t
  :init
  (fido-mode 0)
  (vertico-mode))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator)
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)))

(use-package corfu-popupinfo
  :ensure nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (corfu-popupinfo-mode))

(use-package corfu-terminal
  :if (not (display-graphic-p))
  :ensure t
  :config
  (corfu-terminal-mode))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package kind-icon
  :if (display-graphic-p)
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless)))

;;; --------------------[ Navigation and actions ]------------------------------

(use-package avy
  :ensure t
  :bind (("C-c j l" . avy-goto-line)
         ("C-c j c" . avy-goto-char-timer)
         ("C-c j w" . avy-goto-word-0)))

(use-package consult
  :ensure t
  :bind (("C-x b"   . consult-buffer)
         ("M-y"     . consult-yank-pop)
         ("C-s"     . consult-line)
         ("C-c s s" . consult-line)
         ("C-c s r" . consult-ripgrep)
         ("C-c s o" . consult-outline)
         ("C-c s e" . consult-flymake))
  :config
  (setq consult-narrow-key "<"))

(use-package embark
  :ensure t
  :bind (("C-." . embark-act)))        ; bind this to an easy key to hit

(use-package embark-consult
  :ensure t)

;;; --------------------[ Editing utilities ]-----------------------------------

;; This performs poorly on Windows, so I don't enable it on my work machine.
(when (not my-work-machine-p)
  (use-package pulsar
    :ensure t
    :init
    (setq pulsar-pulse t
          pulsar-delay 0.055
          pulsar-iterations 10)
    (pulsar-global-mode 1)))

;;; --------------------[ Org-mode ]--------------------------------------------

(defun fold-done-entries ()
  "Fold all enteries marked DONE."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (while (outline-previous-heading)
      (when (org-entry-is-done-p)
        (hide-subtree)))))

(use-package org
  :init
  (setq org-hide-emphasis-markers nil
        org-adapt-indentation nil
        org-log-into-drawer t
        org-log-done 'time
        org-use-fast-todo-selection t)
  (setq org-todo-keywords
        '((sequence "INBOX(i)" "MAYBE(m)" "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  :hook
  (org-mode . fold-done-entries))

(setq org-directory "~/memex")
(setq org-agenda-files (nconc
                        '("gtd.org")
                        (directory-files-recursively org-directory ".*_area.*\.org$")
                        (directory-files-recursively org-directory ".*_project.*\.org$")))

;; This is where capture will place new content by default
(setq org-default-notes-file (concat org-directory "/gtd.org"))

(add-hook 'org-mode-hook 'turn-on-auto-fill)
(add-hook 'org-mode-hook (lambda ()
			                     (setq-local show-trailing-whitespace t)))

(define-key global-map (kbd "C-c o c") 'org-capture)
(define-key global-map (kbd "C-c o a") 'org-agenda)
(define-key global-map (kbd "C-c o l") 'org-store-link)

(setq org-pretty-entities t)
(setq org-fontify-quote-and-verse-blocks t)
(setq org-hierarchical-todo-statistics nil)

(defun am/org-last-heading ()
  "Go to last visible org heading."
  (interactive)
  (progn (goto-char (point-max))
         (outline-previous-heading)))

(defun am/org-archive-done-in-subtree ()
  "Archive all DONE entries within the current subtree."
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (outline-previous-heading)))
   "/DONE" 'tree))

(setq org-capture-templates
      '(("t" "Task" entry
         (file org-default-notes-file)
         "* INBOX %?\n" :empty-lines 1)
        ("j" "Journal" entry
         (file denote-journal-path-to-new-or-existing-entry)
         "* %U %?\n%i\n%a"
         :kill-buffer t
         :empty-lines 1)
        ("w" "Weight" table-line
         (file+olp "~/memex/health.org" "Weight" "Data")
         "| %U | %? | " :unnarrowed t)))

(setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)

;; A project is "stuck" if it is a level-2 heading with no NEXT action
(setq org-stuck-projects
      '("+LEVEL=2/-DONE-CNCL" ("NEXT") nil ""))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (scheme . t)
   (lisp . t)
   (octave . t)
   (shell . t)))

(when my-laptop-p
  (setq python-shell-interpreter "/usr/local/bin/python3"))

(setq org-babel-python-command "python3")
(setq org-babel-scheme-command "mit-scheme")
(setq org-babel-lisp-eval-fn #'sly-eval)

;;; --------------------[ Denote ]----------------------------------------------

(use-package denote
  :ensure t
  :after org
  :hook (dired-mode . denote-dired-mode)
  :init
  (denote-rename-buffer-mode)
  :custom
  (denote-sort-keywords t)
  (denote-directory (concat org-directory "/"))
  (denote-known-keywords '("literature", "idea", "project", "index", "area", "resource"))
  :bind (("C-c n r" . denote-rename-file)
         ("C-c n n" . denote-create-note)
         ("C-c n l" . denote-link-or-create)
         ("C-c n b" . denote-find-backlink)
         ("C-c n f" . denote-open-or-create)))

(use-package denote-explore
  :ensure t)

(use-package denote-journal
  :ensure t
  :commands (denote-journal-new-entry
             denote-journal-new-or-existing-entry
             denote-journal-link-or-create-entry)
  :hook (calendar-mode . denote-journal-calendar-mode)
  :bind (("C-c n j" . denote-journal-new-or-existing-entry))
  :config
  ;; Use the "journal" subdirectory of the `denote-directory'.  Set this to
  ;; nil to use the `denote-directory' instead.
  (setq denote-journal-directory
        (expand-file-name "journal" denote-directory))
  ;; Default keyword for new journal entries.  It can also ba a list of
  ;; strings.
  (setq denote-journal-keyword "journal")
  ;; Read the doc string of `denote-journal-title-format'.
  (setq denote-journal-title-format 'day-date-month-year))

;;; --------------------[ Dired ]-----------------------------------------------

(use-package dired
  :init
  (setq dired-dwim-target t)
  :hook (dired-mode . dired-hide-details-mode))

;;; --------------------[ Magit ]-----------------------------------------------

(use-package magit
  :ensure t
  :bind (("C-x g"   . magit-status)
         ("C-c g s" . magit-status)
         ("C-c g b" . magit-blame)
         ("C-c g l" . magit-log-current)))

;;; --------------------[ Development tools ]-----------------------------------

(use-package eglot
  :ensure t
  :hook
  ((rust-mode . rust-ts-mode))
  ;; :config
  ;; (add-to-list 'eglot-server-programs
  ;;              '(python-mode . ("/Library/Frameworks/Python.framework/Versions/3.11/bin/jedi-language-server")))
  :custom
  (eglot-send-changes-idle-time 0.1))

(use-package sly
  :ensure t
  :config
  (setq inferior-lisp-program "sbcl"))

(use-package geiser-guile
  :ensure t)

(use-package paredit
  :ensure t
  :hook ((scheme-mode . paredit-mode)
         (geiser-repl-mode . paredit-mode)
         (emacs-lisp-mode . paredit-mode)))

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package flycheck
  :ensure)

(use-package flycheck-eglot
  :ensure)

(use-package elpy
  :ensure t
  :init
  (elpy-enable))

(use-package rust-mode
  :ensure t
  :bind
  (("C-c r r" . rust-run)
   ("C-c r f" . rust-format-buffer)))

(use-package go-mode
  :ensure t
  :hook
  (go-mode . (lambda () (setq tab-width 8)))
  )

(use-package flymake-proselint
  :ensure t
  :config
  (add-hook 'org-mode-hook #'flymake-proselint-setup))

;;; --------------------[ Shell and terminal ]----------------------------------

(use-package eshell
  :init
  (defun my/setup-eshell ()
    (keymap-set eshell-mode-map "C-r" 'consult-history))
  :hook ((eshell-mode . my/setup-eshell)))

(use-package eat
  :ensure t
  :custom
  (eat-term-name "xterm")
  :config
  (eat-eshell-mode)
  (eat-eshell-visual-command-mode))

;;; --------------------[ Media ]-----------------------------------------------

;; I go back and forth between using EMMS and bongo but am considering using
;; Elsa or something else instead.

(use-package emms
  :ensure t
  :init
  (emms-all)
  (setq emms-info-functions '(emms-info-native
                              emms-info-metaflac
                              emms-info-ogginfo))
  (emms-default-players)
  :bind (("C-c m p" . emms-pause)
         ("C-c m m" . emms)
         ("C-c m r" . emms-random)
         ("C-c m v" . emms-volume-minor-mode)))

;;; --------------------[ Timers ]----------------------------------------------

(use-package tmr
  :ensure t
  :custom
  (tmr-sound-file nil))

(defun start-pomodoro (task)
  "Start a Pomodoro"
  (interactive "sTask: ")
  (tmr-with-description "25m" task))

(defun start-short-break ()
  "Start a short break"
  (interactive)
  (tmr-with-description "5m" "Short break"))

(defun brew-hojicha ()
  "Brew hojicha"
  (interactive)
  (tmr-with-description "3m" "Hojicha"))

(global-set-key (kbd "C-c t p") 'start-pomodoro)
(global-set-key (kbd "C-c t b") 'start-short-break)
(global-set-key (kbd "C-c t g") 'brew-hojicha)
(global-set-key (kbd "C-c t t") 'tmr-tabulated-view)

;;; --------------------[ LLMs ]------------------------------------------------

(use-package claude-code-ide
  :vc (:url "https://github.com/manzaltu/claude-code-ide.el" :rev :newest)
  :bind ("C-c e c" . claude-code-ide-menu)
  :config
  (claude-code-ide-emacs-tools-setup))

;; gptel: Claude API integration for chat and code assistance
;; Requires ANTHROPIC_API_KEY set in the environment (see config.fish)
(use-package gptel
  :ensure t
  :bind (("C-c <return>" . gptel-send)
         ("C-c e g"      . gptel))
  :config
  (setq gptel-model 'claude-sonnet-4-6
        gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key (getenv "ANTHROPIC_API_KEY"))))

;; ;; claude-code: Run Claude Code CLI inside Emacs via eat
;; (use-package claude-code
;;   :ensure t
;;   :commands (claude-code claude-code-transient)
;;   :bind-keymap ("C-c e c" . claude-code-command-map)
;;   :init
;;   (setq claude-code-terminal-backend 'eat))

(use-package ellama
  :ensure t
  :bind ("C-c e e" . ellama-transient-main-menu)
  :init
  (require 'llm-ollama)
  (setq ellama-providers
        '(("gemma3" . (make-llm-ollama
                           :chat-model "gemma3:latest"))
          ("gemma3-27b" . (make-llm-ollama
                           :chat-model "gemma3:27b"))
          ("gemma2" . (make-llm-ollama
                       :chat-model "gemma2:latest"))
          ("llama3" . (make-llm-ollama
                       :chat-model "llama3:latest"))
          ("qwen3" . (make-llm-ollama
                      :chat-model "qwen3:latest"))
          ("deepseek" . (make-llm-ollama
                         :chat-model "deepseek-r1:latest")))))

;;; --------------------[ Markdown ]--------------------------------------------

(use-package markdown-mode
  :ensure t
  :hook (markdown-mode . visual-line-mode)
  :custom
  (visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
  :init
  (setq-default markdown-enable-wiki-links t
                markdown-hide-urls nil
                markdown-hide-markup nil))

;;; --------------------[ Useful functions ]------------------------------------

(defun fill-to-eol (char)
  "Fill a character from point until column 80."
  (interactive "cChar: ")
  (insert-char char 80)
  (move-to-column 80)
  (kill-line))

(defun insert-comment-header (title)
  "Create a Lisp comment header with a given title."
  (interactive "sTitle: ")
  (insert ";;; --------------------[ ")
  (insert title)
  (insert " ]")
  (fill-to-eol ?\-))

(defun random-list-element (x)
  (nth (random (length x)) x))

(defun choose-from (x)
  "Choose at random from a space-dilimited list of choices."
  (interactive "sChoices: ")
  (let ((y (split-string x)))
    (message "Chose: %s" (random-list-element y))))

(defun random-line ()
  "Go to a random line in the buffer."
  (interactive)
  (goto-line (1+ (random (count-lines (point-min) (point-max))))))

(defun my/org-update-heading-count ()
  "Set the leading number in the current Org heading to the count of
top-level list items in its section."
  (interactive)
  (save-excursion
    (org-back-to-heading t)
    (let ((end (save-excursion (org-end-of-subtree t t) (point)))
          (count 0))
      (forward-line 1)
      (while (re-search-forward "^\\([0-9]+[.)]\\|[-+]\\)[ \t]+" end t)
        (setq count (1+ count)))
      (org-back-to-heading t)
      (let ((title (org-get-heading t t t t)))
        (org-edit-headline
         (if (string-match "\\`[0-9]+[ \t]+\\(.*\\)" title)
             (format "%d %s" count (match-string 1 title))
           (format "%d %s" count title)))))))

;;; --------------------[ Macros ]----------------------------------------------

(defalias 'tvdb
  (kmacro "C-y C-u C-SPC \" C-d C-d M-l <escape> SPC - <escape> SPC C-e <backspace> \""))

;; Return `gc-cons-threshold' to its initial value stored in `early-init.el'
(setq gc-cons-threshold am/initial-gc-cons-threshold)

;;; init.el ends here
