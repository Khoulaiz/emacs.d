(require 'cask "/usr/local/share/emacs/site-lisp/cask.el")
(cask-initialize)

(require 'use-package)

(load-theme 'monokai t)

(defun wh/edit-init-file ()
  "Edit the init file, usually `~/.emacs.d/init.el`."
  (interactive)
  (find-file (or user-init-file "")))

(defun wh/newline-and-indent-like-previous-line ()
  (interactive)
  (newline)
  (indent-relative-maybe))

(defun wh/eval-surrounding-sexp ()
  (interactive)
  (save-excursion
    (up-list)
    (eval-last-sexp nil)))

(defun wh/create-bash-script (name)
  "Create a bash script in ~/bin.

The script will be called `NAME'. A bash shebang will be inserted on the first
line and the script will be made executable for the user."
  (interactive "sName: ")
  (let ((path (concat "~/bin/" name)))
    (find-file path)
    (insert "#!/bin/bash\n\n\n")
    (end-of-buffer)
    (save-buffer)
    (shell-script-mode)
    (shell-command (format "chmod u+x %s" path))))

(global-set-key (kbd "<f2>") 'wh/edit-init-file)
(global-set-key (kbd "C-k") 'kill-whole-line)

(require 'dired-x)
(define-key dired-mode-map (kbd "SPC") nil)

;; Always as "y or n", not that annoying "yes or no".
(defalias 'yes-or-no-p 'y-or-n-p)

(when (getenv "TMUX")
  (define-key key-translation-map "\M-[1;5C" (kbd "C-<right>"))
  (define-key key-translation-map "\M-[1;5D" (kbd "C-<left>"))
  (define-key input-decode-map "\e[1;5A" [C-up])
  (define-key input-decode-map "\e[1;5B" [C-down]))

;; Evil.

;; Modes for which <leader> works in Emacs state.
(setq evil-leader/no-prefix-mode-rx '("magit-.*-mode"))

(global-evil-leader-mode)
(evil-mode 1)

;; Use Emacs keybindings when in insert mode.
(setcdr evil-insert-state-map nil)
(define-key evil-insert-state-map [escape] 'evil-normal-state)

(define-key evil-insert-state-map (kbd "<RET>") 'newline-and-indent)

;; Evil mode keys.
(evil-leader/set-leader "<SPC>")

(define-key evil-normal-state-map (kbd "-") 'dired-jump)
(define-key evil-normal-state-map (kbd "C-a") 'back-to-indentation)
(define-key evil-normal-state-map (kbd "H") 'back-to-indentation)
(define-key evil-normal-state-map (kbd "C-e") 'move-end-of-line)
(define-key evil-normal-state-map (kbd "L") 'move-end-of-line)
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

(define-key evil-visual-state-map (kbd "a") 'align-regexp)

;; Modes that don't use evil.
(mapcar (lambda (mode) (add-to-list 'evil-emacs-state-modes mode))
        '(inferior-emacs-lisp-mode
          alchemist-iex-mode
          cider-repl-mode
          cider-stacktrace-mode
          magit-popup-mode
          magit-popup-sequence-mode))

(define-key dired-mode-map (kbd "-") 'dired-up-directory)

(evil-leader/set-key
  "!" 'shell-command
  ":" 'eval-expression
  "o" 'other-window
  "b" 'switch-to-buffer)

(evil-leader/set-key-for-mode 'emacs-lisp-mode
  "e d" 'eval-defun
  "e s" 'wh/eval-surrounding-sexp
  "h" 'describe-function)

(use-package evil-commentary
  :config
  (evil-commentary-mode))

(use-package evil-terminal-cursor-changer)

(use-package evil-surround
  :config
  (progn
    (global-evil-surround-mode 1)
    (evil-define-key 'visual evil-surround-mode-map "s" 'evil-surround-region)))

(use-package evil-exchange
  :load-path "ext"
  :demand
  :config
  (evil-exchange-install))

;; Misc packages.

(use-package pallet
  :config
  (pallet-mode t))

(use-package magit
  :config
  (progn
    (evil-leader/set-key "g s" 'magit-status)
    (define-key magit-status-mode-map (kbd "j") 'magit-goto-next-section)
    (define-key magit-status-mode-map (kbd "k") 'magit-goto-previous-section)))

(use-package github-browse-file
  :config
  (evil-leader/set-key "g b" 'github-browse-file))

(use-package helm
  :init
  (setq helm-M-x-fuzzy-match t)
  (setq helm-apropos-fuzzy-match t)
  :bind
  ("M-x" . helm-M-x)
  :config
  (progn
    (helm-mode t)
    (evil-leader/set-key "<SPC>" 'helm-M-x)))

(use-package helm-ag
  :config
  (progn
    (evil-leader/set-key "a g" 'helm-do-ag-project-root)
    (evil-leader/set-key "a G" 'helm-do-ag)))

(use-package projectile
  :init
  (setq projectile-completion-system 'grizzl)
  :config
  (progn
    (evil-leader/set-key "f" 'projectile-find-file)
    (projectile-global-mode)))

(use-package guide-key
  :init
  (setq guide-key/guide-key-sequence t)
  (setq guide-key/idle-delay 0.4)
  :config
  (guide-key-mode 1))

(use-package popwin
  :config
  (progn
    (mapcar (lambda (el) (add-to-list 'popwin:special-display-config el))
            '(helm-mode
              ("*Help*" :stick t)
              ("*mix*" :position bottom :noselect t)
              ("*alchemist-test-report*" :position bottom :tail t :stick t)))
    (popwin-mode 1)))

(use-package company
  :init
  (setq company-idle-delay 0.10)
  :config
  (progn
    (global-set-key (kbd "C-n") 'company-manual-begin)
    (define-key company-active-map (kbd "C-n") 'company-select-next)
    (define-key company-active-map (kbd "C-p") 'company-select-previous)
    (define-key company-active-map (kbd "TAB") 'company-complete-selection)
    (define-key company-active-map (kbd "RET") nil)
    (global-company-mode t)))

(defun wh/toggle-tmux-status-bar (activate?)
  (let ((cmd (if activate? "tmux set status off" "tmux set status on")))
    (shell-command cmd)))

(use-package writeroom-mode
  :demand
  :init
  (evil-leader/set-key "m w" 'writeroom-mode)
  :config
  (add-to-list 'writeroom-global-effects 'wh/toggle-tmux-status-bar))

(use-package highlight-sexp
  :load-path "ext"
  :init
  (add-hook 'clojure-mode-hook 'hl-sexp-mode)
  (add-hook 'racket-mode-hook 'hl-sexp-mode)
  (add-hook 'emacs-lisp-mode-hook 'hl-sexp-mode))

(use-package hl-todo
  :config
  (global-hl-todo-mode))

;; Modes for programming languages and such.

(use-package web-mode
  :init
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  :mode (("\\.html\\.erb\\'" . web-mode)))

(use-package scss-mode
  :init
  (setq css-indent-offset 2))

(use-package erlang
  :init
  (setq erlang-indent-level 4))

(use-package elixir-mode
  :load-path "~/Code/emacs-elixir"
  :demand)

(defun wh/alchemist-mix-deps-get ()
  "Fetch the dependencies of the current Mix project with the deps.get task."
  (interactive)
  (alchemist-mix-deps-with-prompt "deps.get"))

(use-package alchemist
  :load-path "~/Code/alchemist.el"
  :demand
  :config
  (progn
    (evil-define-key 'normal alchemist-test-mode-map "]t" 'alchemist-test-mode-jump-to-next-test)
    (evil-define-key 'normal alchemist-test-mode-map "[t" 'alchemist-test-mode-jump-to-previous-test)
    (define-key evil-normal-state-map "]d" 'alchemist-goto-jump-to-next-def-symbol)
    (define-key evil-normal-state-map "[d" 'alchemist-goto-jump-to-previous-def-symbol)
    (define-key alchemist-mode-map (kbd "C-c a d g") 'wh/alchemist-mix-deps-get)
    (evil-leader/set-key-for-mode 'elixir-mode
      "t b" 'alchemist-mix-test-this-buffer
      "t t" 'alchemist-mix-test
      "t r" 'alchemist-mix-rerun-last-test
      "t p" 'alchemist-mix-test-at-point)))

(use-package markdown-mode
  :init
  (setq markdown-open-command "marked")
  :mode (("\\.md\\'" . gfm-mode)
         ("\\.mkd\\'" . gfm-mode)
         ("\\.markdown\\'" . gfm-mode))
  :config
  (progn
    (add-hook 'gfm-mode-hook
              (lambda ()
                (local-set-key (kbd "RET") 'wh/newline-and-indent-like-previous-line)
                (local-set-key (kbd "DEL") 'backward-delete-char-untabify)))))

(use-package projectile-rails
  :config
  (add-hook 'projectile-mode-hook 'projectile-rails-on))

(use-package racket-mode)

;; Miscellaneous stuff.

;; Remove trailing whitespace on save.
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Show trailing whitespace on programming modes.
(add-hook 'prog-mode-hook
          '(lambda () (setq-default show-trailing-whitespace t)))

;; Correctly load $PATH and $MANPATH on OSX (GUI).
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; Show matching parentheses.
(show-paren-mode 1)

;; Show the column number in the modeline.
(column-number-mode 1)


;; Backup and autosave files in /tmp.
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))


;; Indentation is two spaces wide, with spaces instead of tabs.
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; Wrap at 80 characters.
(setq-default fill-column 80)

;; Ensure there's a trailing newline, always.
(setq require-final-newline t)



;; Visual minor modes.

;; Pretty symbols!
(global-prettify-symbols-mode t)

;; Font size in 1/10pt (140 = 14 pt).
(set-face-attribute 'default nil :height 140)

(setq font-lock-maximum-decoration t)


;; Don't display the start messages when Emacs starts.
(setq inhibit-splash-screen t
      inhibit-startup-echo-area-message t
      inhibit-startup-message t)

;; Hide all the intrusive GUI features.
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; Don't flash any alarms.
(setq ring-bell-function 'ignore)

;; Left Option is Meta, right Option doesn't do anything in Emacs (so it can be
;; used for accented letters and such).
(setq mac-option-key-is-meta t)
(setq mac-right-option-modifier nil)

;; ;; Start with a maximized window.
;; (toggle-frame-fullscreen)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("05c3bc4eb1219953a4f182e10de1f7466d28987f48d647c01f1f0037ff35ab9a" default)))
 '(magit-use-overlays nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
