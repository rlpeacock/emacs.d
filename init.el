;; ===========================================================================
;; package setup
;; ===========================================================================

(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; Haven't really tested this, but in theory I can bootstrap config on a new
;; server this way. The other way to do this is with package-install-selected-packages,
;; but the requisite variable isn't bound until the end of init, so it needs to be
;; manually set before use.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; use-package should always install a package if it's not already installed
(require 'use-package-ensure)
(setq use-package-always-ensure t)

;; add and configure packages
(use-package ag)
(use-package company)
(use-package company-go)
(use-package expand-region)
(use-package fish-mode)
(use-package fish-completion)
(use-package flycheck)
(use-package flycheck-golangci-lint)
(use-package flycheck-projectile)
(use-package flycheck-pycheckers)
(use-package flycheck-rust)
(use-package flymake)
(use-package flymake-aspell)
(use-package flymake-css)
(use-package flymake-diagnostic-at-point)
(use-package flymake-eslint)
(use-package flymake-go)
(use-package flymake-go-staticcheck)
(use-package git-gutter)
(use-package git-gutter-fringe)
(use-package go-dlv)
(use-package go-fill-struct)
(use-package go-mode
  :config
  (add-hook 'go-mode-hook #'lsp))
(use-package go-playground)
(use-package go-projectile)
(use-package go-rename)
(use-package ido)
(use-package lsp-mode
  :commands lsp)
(use-package magit)
(use-package material-theme)
(use-package minions)
(use-package multiple-cursors)
(use-package org-roam)
;(use-package org-tempo)
(use-package projectile)
(use-package projectile-speedbar)
(use-package rust-mode)
(use-package rustic)
(use-package typescript-mode)
(use-package use-package)
(use-package vue-html-mode)
(use-package vue-mode
  :mode "\\.vue\\'"
  :config
  (add-hook 'vue-mode-hook #'lsp))

;; ===========================================================================
;; minor modes and setting tweaks
;; ===========================================================================

(global-linum-mode 0)
(add-to-list 'exec-path "/usr/local/bin/")
(add-to-list 'exec-path "~/.cargo/bin")
(add-to-list 'exec-path "~/go/bin")
(tool-bar-mode 0)
(if (boundp 'scroll-bar-mode)
    (scroll-bar-mode 0))
(show-paren-mode 1)
(column-number-mode 1)
(fset 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
(setq-default kill-whole-line 1)
(set-default-coding-systems 'utf-8)
(setq-default indent-tabs-mode 0)
(setq-default tab-width 4)
(ido-mode)
(minions-mode)
;; don't even remember what this is
;(use-package org-tempo)
(setq-default kill-whole-line 1)
(xterm-mouse-mode)
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq ring-bell-function 'ignore)
(global-git-gutter-mode +1)
(projectile-mode +1)
(setq ring-bell-function 'ignore)
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/Documents/notes/tasks.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("j" "Journal" entry (file+datetree "~/Documents/notes/journal.org")
         "* %?\nEntered on %U\n  %i\n  %a" :epmty-lines-before 1)
		("s" "Snippet" entry (file "~/Documents/notes/snippets.org")
		 "* %?\n#+BEGIN_SRC\n%c\n#+END_SRC"  :empty-lines-before 1)))
;; mac specific settings
;; todo: do I want mouse and clip on Linux?
(if (string-equal system-type "darwin")
    (progn
      (xterm-mouse-mode)
      ;(xclip-mode)
	  (add-to-list 'exec-path "/opt/homebrew/bin/")
      (defun up-slightly () (interactive) (scroll-up 2))
      (defun down-slightly () (interactive) (scroll-down 2))
      (global-set-key [mouse-4] 'down-slightly)
      (global-set-key [mouse-5] 'up-slightly)))

;; increase GC threshold for LSP (which generates a lot of garbage)
(setq gc-cons-threshold 100000000)
;; LSP reads very large objects
(setq read-process-output-max (* 1024 1024))

;; ===========================================================================
;; cosmetics
;; ===========================================================================

(set-face-attribute 'default nil :height 150)
(setq-default line-spacing 3)
;; not sure about these
;; (setq-default left-fringe-width 10)
;; (setq-default right-fringe-width 10)
;; (set-face-attribute 'default nil :height 140)
;; (set-face-attribute 'mode-line nil :background "#E0E0E6" :foreground "#888" :box '(:line-width 2 :color "#E0E0E6"))
;; (set-face-attribute 'fringe nil :background "#FFF")
(load-theme 'material t)
;; simplify ibuffer
(setq ibuffer-formats
      '((mark modified read-only " "
	      (name 24 24 :left :elide)
	      " "
	      filename-and-process)))

;; ===========================================================================
;; functions
;; ===========================================================================


(defun xah-select-line ()
  "Select current line. If region is active, extend selection downward by line.
URL `http://xahlee.info/emacs/emacs/modernization_mark-word.html'
Version 2017-11-01"
  (interactive)
  (if (region-active-p)
      (progn
        (forward-line 1)
        (end-of-line))
    (progn
      (end-of-line)
      (set-mark (line-beginning-position)))))


(defun rlp-ibuffer-hook ()
  "Hook to make a single click open a buffer when in ibuffer"
  (define-key ibuffer-name-map [mouse-1] 'ibuffer-visit-buffer)
  (define-key ibuffer-mode-map [mouse-1] 'ibuffer-visit-buffer))
  
(add-hook 'ibuffer-mode-hook 'rlp-ibuffer-hook)

(defun rlp-clickity-click ()
  "Rigth click on right side or bottom of window will open a new window. Otherwise close window"
  (interactive)
  (let* ((pos (mouse-position))
	 (frame (car pos))
	 (fx (cadr pos))
	 (fy (cddr pos))
	 (win (window-at fx fy))
	 (rel-pos (coordinates-in-window-p (cdr pos) win))
	 (x (car rel-pos))
	 (y (cdr rel-pos))
	 (height (window-body-height win))
	 (width (window-body-width win))
	 (px (/ (float x) width))
	 (py (/ (float y) height))
	 (close-boundary 0.80))
    (select-window win)
    (if (and (> px close-boundary) (< py close-boundary))
	(split-window-right)
      (if (and (< px close-boundary) (> py close-boundary))
	  (split-window-below)
	(delete-window win)))))

;; not actually using org-roam
;; (setq org-roam-directory (file-truename "~/Dropbox/Documents/notes"))
;; (org-roam-db-autosync-mode)

;; ===========================================================================
;; key bindings
;; ===========================================================================

;; experimental keybindings using new prefix
(define-prefix-command 'rob-map)
(global-set-key (kbd "C-;") 'rob-map)
(global-set-key (kbd "C-; s") 'save-buffer)
(global-set-key (kbd "C-; o") 'other-window)
(global-set-key (kbd "C-; b") 'ibuffer)
(global-set-key (kbd "C-; r") 'query-replace)
(global-set-key (kbd "C-; e") 'eval-last-sexp)
(global-set-key (kbd "C-; k") 'ido-kill-buffer)
(global-set-key (kbd "C-; 1") 'delete-other-windows)
(global-set-key (kbd "C-; 2") 'split-window-below)
(global-set-key (kbd "C-; 3") 'split-window-right)
(global-set-key (kbd "C-; w") 'kill-ring-save)
(global-set-key (kbd "C-; t") 'dabbrev-expand)
;(global-set-key (kbd "C-; c") 'kill-ring-save)
(global-set-key (kbd "C-; x") 'kill-region)
(global-set-key (kbd "C-; p") 'yank)
(global-set-key (kbd "C-; <return>") 'org-meta-return)
;; rebind common stuff for less chording
(global-set-key (kbd "C-f") 'isearch-forward) ; and less ring finger
(define-key isearch-mode-map (kbd "C-f") 'isearch-repeat-forward)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-q") 'save-buffers-kill-terminal)
(global-set-key (kbd "C-o") 'ido-find-file)
(global-set-key (kbd "C-b") 'ibuffer)
(global-set-key (kbd "C-z") 'undo)

(global-set-key (kbd "s-f") 'isearch-forward)
(define-key isearch-mode-map (kbd "s-f") 'isearch-repeat-forward)
(global-set-key (kbd "s-<right>") 'windmove-right)
(global-set-key (kbd "s-<left>") 'windmove-left)
(global-set-key (kbd "s-s") 'save-buffer)
(global-set-key (kbd "s-o") 'ido-find-file)
(global-set-key (kbd "s-b") 'ibuffer)
(global-set-key (kbd "s-r") 'query-replace)
(global-set-key (kbd "s-e") 'eval-last-sexp)
(global-set-key (kbd "s-k") 'ido-kill-buffer)
(global-set-key (kbd "s-1") 'delete-other-windows)
(global-set-key (kbd "s-2") 'split-window-below)
(global-set-key (kbd "s-3") 'split-window-right)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-t") 'dabbrev-expand)
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-n") 'make-frame-command)
(global-set-key (kbd "s-q") 'save-buffers-kill-terminal)
(global-set-key (kbd "C-j") 'xah-select-line)
(global-set-key (kbd "s-l") 'xah-select-line)

;; mode keybindings

;; git-gutter
(global-git-gutter-mode +1)
(global-set-key (kbd "C-; g p") 'git-gutter:previous-hunk)
(global-set-key (kbd "C-; g n") 'git-gutter:next-hunk)
(global-set-key (kbd "C-; g r") 'git-gutter:revert-hunk)

;; multi-cursor
(global-set-key (kbd "s-d") 'mc/mark-next-like-this-word)
(global-set-key (kbd "s-j") 'mc/mark-next-like-this) ;; what's this?

;; expand-rgion
(global-set-key (kbd "s-e") 'er/expand-region)

;; projectile
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; org and org-roam
(global-set-key (kbd "C-; c") 'org-roam-capture)
(global-set-key (kbd "C-; n i") 'org-roam-node-insert)
(global-set-key (kbd "C-; n f") 'org-roam-node-find)
(global-set-key (kbd "C-; n b") 'org-roam-buffer-toggle)
(global-set-key (kbd "C-; n d") 'org-roam-display-dedicated)

;; erc
(add-hook 'erc-mode-hook
          '(lambda ()
             (define-key erc-mode-map (kbd "s-<return>") 'erc-send-current-line)))


;; mouse bindings - work in progress
(global-set-key [double-mouse-1] 'split-window-below)
;;(global-set-key [mouse-2] 'split-window-below) ; doesn't work on mac
(global-set-key [mouse-3] 'rlp-clickity-click)
;(global-set-key [mouse-3] 'mouse-delete-window)
;; clicking on filename in the modeline will bring up ibuffer
(define-key mode-line-buffer-identification-keymap [mode-line mouse-1] 'ibuffer)

;; ===========================================================================
;; customize
;; ===========================================================================

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("db86c52e18460fe10e750759b9077333f9414ed456dc94473f9cf188b197bc74" default))
 '(lsp-client-packages
   '(ccls lsp-actionscript lsp-ada lsp-angular lsp-ansible lsp-astro lsp-bash lsp-beancount lsp-clangd lsp-clojure lsp-cmake lsp-crystal lsp-csharp lsp-css lsp-d lsp-dart lsp-dhall lsp-docker lsp-dockerfile lsp-elm lsp-elixir lsp-emmet lsp-erlang lsp-eslint lsp-fortran lsp-fsharp lsp-gdscript lsp-go lsp-gleam lsp-graphql lsp-hack lsp-grammarly lsp-groovy lsp-haskell lsp-haxe lsp-idris lsp-java lsp-javascript lsp-json lsp-kotlin lsp-latex lsp-ltex lsp-lua lsp-markdown lsp-marksman lsp-mint lsp-nginx lsp-nim lsp-nix lsp-magik lsp-metals lsp-mssql lsp-ocaml lsp-openscad lsp-pascal lsp-perl lsp-perlnavigator lsp-pls lsp-php lsp-pwsh lsp-pyls lsp-pylsp lsp-pyright lsp-python-ms lsp-purescript lsp-r lsp-racket lsp-remark lsp-rf lsp-rust lsp-solargraph lsp-sorbet lsp-sourcekit lsp-sonarlint lsp-tailwindcss lsp-tex lsp-terraform lsp-toml lsp-ttcn3 lsp-typeprof lsp-v lsp-vala lsp-verilog lsp-volar lsp-vhdl lsp-vimscript lsp-xml lsp-yaml lsp-ruby-syntax-tree lsp-sqls lsp-svelte lsp-steep lsp-zig))
 '(lsp-disabled-clients '(vetur))
 '(package-selected-packages
   '(fish-completion fish-mode org-tempo flycheck-golangci-lint flycheck-pycheckers flymake flymake-aspell flymake-css flymake-diagnostic-at-point flymake-eslint flymake-go-staticcheck go-dlv go-fill-struct flymake-go go-mode go-playground go-rename ag flycheck-rust rustic org-roam git-gutter-fringe multiple-cursors rust-mode typescript-mode flycheck-projectile go-projectile projectile projectile-speedbar company company-go flycheck use-package lsp-mode vue-html-mode vue-mode magit material-theme))
 '(rustic-analyzer-command '("/home/rob/.cargo/bin/rust-analyzer"))
 '(typescript-auto-indent-flag nil)
 '(typescript-indent-level 2)
 '(typescript-indent-list-items nil)
 '(typescript-indent-switch-clauses nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mmm-default-submode-face ((t nil))))

