;; ===========================================================================
;; package setup
;; ===========================================================================

(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; use-package should always install a package if it's not already installed
(require 'use-package-ensure)
(setq use-package-always-ensure t)
;; workaround for bug in treemacs that barfs because it doesn't know what svg is
;; see: https://github.com/emacs-lsp/lsp-mode/issues/4054
(add-to-list 'image-types 'svg)
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
(use-package go-snippets)
(use-package ido)
(use-package lsp-mode
  :commands lsp)
(use-package lua-mode)
(use-package magit)
(use-package material-theme)
(use-package minions)
(use-package multiple-cursors)
(use-package org-roam)
;;(use-package org-tempo)
(use-package project-treemacs)
(use-package projectile)
(use-package projectile-speedbar)
(use-package request)
(use-package rust-mode)
(use-package rustic)
(use-package lsp-treemacs
  :config
  ;; sync between lsp project and treemacs project
  (lsp-treemacs-sync-mode 1))
(use-package typescript-mode)
(use-package use-package)
(use-package vue-html-mode)
(use-package vue-mode
  :mode "\\.vue\\'"
  :config
  (add-hook 'vue-mode-hook #'lsp))
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; ===========================================================================
;; minor modes and setting tweaks
;; ===========================================================================

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
(setq-default display-line-numbers t)
(electric-pair-mode t)
(ido-mode)
(minions-mode)
(xterm-mouse-mode)
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq ring-bell-function 'ignore)
(global-git-gutter-mode +1)
(projectile-mode +1)
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
;; format go code on save
(add-hook 'before-save-hook 'gofmt-before-save)

;; erc mode hook
(add-hook 'erc-mode-hook
          '(lambda ()
			 ;; don't remember why I did this
             (define-key erc-mode-map (kbd "s-<return>") 'erc-send-current-line)
			 ;; erc stomps on mode-line-buffer-identification customization.
			 ;; Override it's mode-line setup to use my custom settings.
			 ;; This is copied right out of erc source with stomping bits removed.
			 (defun erc-update-mode-line-buffer (buffer)
			   "Update the mode line in a single ERC buffer BUFFER."
			   (with-current-buffer buffer
				 (let ((spec (format-spec-make
							  ?a (erc-format-away-status)
							  ?l (erc-format-lag-time)
							  ?m (erc-format-channel-modes)
							  ?n (or (erc-current-nick) "")
							  ?N (erc-format-network)
							  ?o (erc-controls-strip erc-channel-topic)
							  ?p (erc-port-to-string erc-session-port)
							  ?s (erc-format-target-and/or-server)
							  ?S (erc-format-target-and/or-network)
							  ?t (erc-format-target)))
					   (process-status (cond ((and (erc-server-process-alive)
												   (not erc-server-connected))
											  ":connecting")
											 ((erc-server-process-alive)
											  "")
											 (t
											  ": CLOSED")))
					   (face (cond ((eq erc-header-line-face-method nil)
									nil)
								   ((functionp erc-header-line-face-method)
									(funcall erc-header-line-face-method))
								   (t
									'erc-header-line))))
				   (setq mode-line-process (list process-status))
				   (when (boundp 'header-line-format)
					 (let ((header (if erc-header-line-format
									   (format-spec erc-header-line-format spec)
									 nil)))
					   (cond (erc-header-line-uses-tabbar-p
							  (set (make-local-variable 'tabbar--local-hlf)
								   header-line-format)
							  (kill-local-variable 'header-line-format))
							 ((null header)
							  (setq header-line-format nil))
							 (t (setq header-line-format
									  (if face
										  (erc-propertize header 'face face)
										header)))))))))))

;; This causes dired to open files in the same window rather than throwing
;; it into another window
(define-key dired-mode-map [mouse-2] 'dired-mouse-find-file)

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

(defun rlp-save-all ()
  "Save modified buffers, but force gofmt for go mode because save-some-buffers doesn't trip before-save-hook"
  (interactive)
  (when (eq major-mode 'go-mode)
	(gofmt))
  (save-some-buffers t))

;; Trigger save-all on focus out
(add-hook 'focus-out-hook 'rlp-save-all)

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
  "Right click on right side or bottom of window will open a new window. Otherwise close window"
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

(defun rlp-ibuffer-switch ()
  "Switch window with mouse pointer to ibuffer"
  (interactive)
  (let* ((pos (mouse-position))
	 (frame (car pos))
	 (fx (cadr pos))
	 (fy (cddr pos))
	 (win (window-at fx fy)))
    (select-window win)
	(ibuffer)))


(defun rlp-hacker-news ()
  (interactive)
  (request "https://hacker-news.firebaseio.com/v0/topstories.json"
  :parser 'json-read
  :success
  (cl-function (lambda (&key data &allow-other-keys)
                 (when data
                   (with-current-buffer (get-buffer-create "*HN Stories*")
					 (org-mode)
                     (erase-buffer)
					 (seq-do (lambda (item)
							   (request (format "https://hacker-news.firebaseio.com/v0/item/%d.json" item)
								 :parser 'json-read
								 :success
								 (cl-function (lambda (&key data &allow-other-keys)
												(when data
												  (if (assoc 'url data)
													  (insert "[["
															  (cdr (assoc 'url data))
															  "]["
															  (cdr (assoc 'title data)) "]]\n")))))))
							   ;;(insert (number-to-string item)))
							 (seq-take data 51))
                     (pop-to-buffer (current-buffer))))))
  :error
  (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                 (message "HN lookup failed: %S" error-thrown)))
  :complete (lambda (&rest _) (message "Got yer news fer ya"))))

(defun rlp-mouse-expand ()
  (interactive)
  (mouse-set-point last-input-event)
  (er/expand-region 1))

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
(global-set-key (kbd "s-<up>") 'windmove-up)
(global-set-key (kbd "s-<down>") 'windmove-down)
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

;; expand-region
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

;; mouse bindings - work in progress
(global-set-key [double-mouse-1] 'er/expand-region)
;;(global-set-key [mouse-2] 'split-window-below) ; doesn't work on mac
(global-set-key [mouse-3] 'rlp-mouse-expand)
;(global-set-key [mouse-3] 'mouse-delete-window)
;; clicking on filename in the modeline will bring up ibuffer
(define-key mode-line-buffer-identification-keymap [mode-line mouse-1] 'rlp-ibuffer-switch)

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
   '(lsp-treemacs lsp-treemaps project-treemaps project-treemacs request ya-snippet lua-mode go-snippets yasnippet org-tempo flycheck-golangci-lint flycheck-pycheckers flymake flymake-aspell flymake-css flymake-diagnostic-at-point flymake-eslint flymake-go-staticcheck go-dlv go-fill-struct flymake-go go-mode go-playground go-rename ag flycheck-rust rustic org-roam git-gutter-fringe multiple-cursors rust-mode typescript-mode flycheck-projectile go-projectile projectile projectile-speedbar company company-go flycheck use-package lsp-mode vue-html-mode vue-mode magit material-theme))
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

