;;; init.el --- Summary
;;; Commentary:
;;; Main EMACS settings file, load settings from parts.

;;; Code:

(put 'upcase-region 'disabled nil)
(defvar emacs-config-dir
  (file-name-directory user-init-file) "Root directory with settings.")

(require 'ispell)
(setq buffer-file-coding-system "utf8-auto-unix"
      create-lockfiles nil
      inhibit-splash-screen t
      inhibit-startup-message t
      initial-major-mode (quote text-mode)
      initial-scratch-message nil
      ispell-program-name "/usr/bin/aspell"
      make-backup-files nil
      truncate-lines 1
      user-full-name "Dunaevsky Maxim")


(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(package-initialize)

(defvar generic-packages
  '(
    ; CORE
    ace-window
    anaconda-mode
    beacon
    centaur-tabs
    company
    company-box
    company-jedi
    company-quickhelp
    company-terraform
    counsel
    dash
    diff-hl
    direnv
    dockerfile-mode
    edit-indirect
    editorconfig
    flycheck
    flycheck-color-mode-line
    flycheck-indicator
    flycheck-pos-tip
    format-all
    go-mode
    helm
    helm-company
    ibuffer
    ivy
    ivy-rich
    json-mode
    lsp-mode ; https://github.com/emacs-lsp/lsp-mode
    lsp-python
    lsp-treemacs
    magit
    markdown-mode
    meghanada
    multiple-cursors
    nlinum
    org
    powerline ; https://github.com/milkypostman/powerline
    projectile
    protobuf-mode
    python-mode
    ;;pyvenv ; https://github.com/jorgenschaefer/pyvenv
    pyenv-mode ; https://github.com/pythonic-emacs/pyenv-mode
    rainbow-delimiters ; https://github.com/Fanael/rainbow-delimiters
    scala-mode
    terraform-mode
    tide
    treemacs
    treemacs-magit
    typescript-mode
    web-beautify
    which-key
    ws-butler
    yaml-mode

	      ; THEMES
    airline-themes
    base16-theme
    doom-themes
    melancholy-theme
    molokai-theme
    monokai-theme
    solarized-theme
    spacemacs-theme
    zenburn-theme
    ) "Packages for any EMACS version: console and UI.")

(defvar graphic-packages
  '(all-the-icons
    all-the-icons-ibuffer ; https://github.com/seagle0128/all-the-icons-ibuffer
    all-the-icons-ivy ; https://github.com/asok/all-the-icons-ivy
    all-the-icons-ivy-rich ; https://github.com/seagle0128/all-the-icons-ivy-rich
    mode-icons
    ) "Packages only for graphical mode.")

(defvar required-packages)
(if (display-graphic-p)
    (setq required-packages (append generic-packages graphic-packages generic-packages))
  (setq required-packages generic-packages))

;; AUTO INSTALL STRAIGHT BOOTSTRAP
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install all required packages
(dolist (package required-packages)
  (straight-use-package package))


;; Now EMACS "see" packages in "straight" directory
(add-to-list 'load-path (expand-file-name "straight" emacs-config-dir))
(fset 'yes-or-no-p 'y-or-n-p) ;;; Shortcuts for yes and no


;; Resize windows
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;; Exit on Ctrl+Q
(global-set-key (kbd "C-q") 'save-buffers-kill-terminal)
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-x k") 'kill-this-buffer)
;;(setq kill-this-buffer-enabled-p 1)

(global-set-key (kbd "C-x o") 'next-multiframe-window)
(global-set-key (kbd "C-x O") 'previous-multiframe-window)


;; Settings for window (not only a Windows!) system.
(defvar default-font-family nil "Default font family.")
(when (display-graphic-p)
  (fringe-mode 2)
  (scroll-bar-mode 0) ;; Off scrollbars
  (tool-bar-mode 0) ;; Off toolbar
  (tooltip-mode 0) ;; No windows for tooltip
  (window-divider-mode 0)
  (set-face-attribute 'default nil :height 110)

  ;; Font settings for Linux and Windows
  (cond
   (
    (string-equal system-type "windows-nt")
    (when (member "Consolas" (font-family-list))
      (setq default-font-family "Consolas")))
   (
    (string-equal system-type "gnu/linux")
    (when (member "DejaVu Sans Mono" (font-family-list))
      (setq default-font-family "DejaVu Sans Mono"))))

  (set-face-attribute 'default nil :family default-font-family))


;;; Save user settings in dedicated file
(setq custom-file (expand-file-name "settings.el" emacs-config-dir))
(when (file-exists-p custom-file)
  (load-file custom-file))


;; Auto-revert mode
(global-auto-revert-mode 1)


;; ENCODING
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)


;; Settings for hotkeys on any layout
(defun cfg:reverse-input-method (input-method)
  "Build the reverse mapping of single letters from INPUT-METHOD."
  (interactive
   (list (read-input-method-name "Use input method (default current): ")))
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (let ((current current-input-method)
        (modifiers '(nil (control) (meta) (control meta))))
    (when input-method
      (activate-input-method input-method))
    (when (and current-input-method quail-keyboard-layout)
      (dolist (map (cdr (quail-map)))
        (let* ((to (car map))
               (from (quail-get-translation
                      (cadr map) (char-to-string to) 1)))
          (when (and (characterp from) (characterp to))
            (dolist (mod modifiers)
              (define-key local-function-key-map
                (vector (append mod (list from)))
                (vector (append mod (list to)))))))))
    (when input-method
      (activate-input-method current))))

(cfg:reverse-input-method 'russian-computer)


(defun xah-new-empty-buffer ()
  "Create a new empty buffer.
New buffer will be named “untitled” or “untitled<2>”, “untitled<3>”, etc.

It returns the buffer (for elisp programing).

URL `http://ergoemacs.org/emacs/emacs_new_empty_buffer.html'
Version 2017-11-01"
  (interactive)
  (let (
	($buf
	 (generate-new-buffer "untitled")))
    (switch-to-buffer $buf)
    (funcall initial-major-mode)
    (setq buffer-offer-save t)
    $buf))


;; Save/close/open
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-S-s") 'write-file)
(global-set-key (kbd "C-r") 'revert-buffer)
(global-set-key (kbd "C-a") 'mark-whole-buffer)
(global-set-key (kbd "M-'") 'comment-or-uncomment-region)
(global-set-key (kbd "C-o") 'dired)


;; Buffers and windows
(global-set-key (kbd "<f7>") 'xah-new-empty-buffer)


(global-set-key (kbd "M-3") 'delete-other-windows)
(global-set-key (kbd "M-4") 'split-window-horizontally)
(global-set-key (kbd "M-5") 'split-window-vertically)
(global-set-key (kbd "M-6") 'balance-windows)


;; Sort lines
(global-set-key (kbd "<f9>") 'sort-lines)

;; Execute commands
(global-set-key (kbd "<esc>") 'keyboard-quit)


;; Switch windows with C-x and arrow keys
(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <left>") 'windmove-left)


(global-set-key (kbd "M--")
                (lambda ()
                  (interactive)
                  (insert "—"))) ;; Long dash by Alt+-

(global-unset-key (kbd "<insert>")) ;; Disable overwrite mode
(global-unset-key (kbd "M-,")) ;; Disable M-, as markers

(when (get-buffer "*scratch*")
  (kill-buffer "*scratch*"))


;; ACE-WINDOW
;; https://github.com/abo-abo/ace-window
(global-set-key (kbd "M-o") 'ace-window)


;; ALL THE ICONS
(when (display-graphic-p)
  (progn
    (cond
     ;; Install fonts in GNU / Linux
     (
      (string-equal system-type "gnu/linux")
      (unless
          (file-directory-p "~/.local/share/fonts/")
        (all-the-icons-install-fonts)))
     (
      ;; Not install fonts in Windows, but print message
      (string-equal system-type "windows-nt")
      (progn (message "Download and install fonts with all-the-icons-install-fonts command."))))))


;; ALL THE ICONS IBUFFER
(when (display-graphic-p)
  (add-hook 'ibuffer-mode-hook #'all-the-icons-ibuffer-mode))


;; ALL THE ICONS IVY RICH
(when (display-graphic-p)
  (all-the-icons-ivy-rich-mode 1))


;; BEACON
(beacon-mode 1)


;; CENTAUR-TABS
;; https://github.com/ema2159/centaur-tabs
(require 'centaur-tabs)
(setq centaur-tabs-style "slant"
      centaur-tabs-set-icons t
      centaur-tabs-set-modified-marker t
      centaur-tabs-gray-out-icons 'buffer
      centaur-tabs-set-bar 'under
      uniquify-separator "/")
(centaur-tabs-mode 1)
(global-set-key (kbd "C-<next>") 'centaur-tabs-forward)
(global-set-key (kbd "C-<prior>") 'centaur-tabs-backward)


;; COMPANY-MODE
;;https://company-mode.github.io/
(require 'company)
(defun setup-company-mode ()
  "Settings for company-mode."
  (interactive)
  (setq company-dabbrev-code-ignore-case nil
        company-dabbrev-downcase nil
        company-dabbrev-ignore-case nil
        company-idle-delay 0
        company-minimum-prefix-length 2
        company-quickhelp-delay 3
        company-tooltip-align-annotations t))
(add-hook 'company-mode-hook #'setup-company-mode)


;; COMPANY-JEDI
;; https://github.com/company-mode/company-mode
(with-eval-after-load "company"
  (add-to-list 'company-backends 'company-jedi))


;; COMPANY-BOX
;; https://github.com/sebastiencs/company-box/
(add-hook 'company-mode-hook 'company-box-mode)


;; COMPANY-QUICKHELP-MODE
;; https://github.com/company-mode/company-quickhelp
(add-hook 'company-mode-hook 'company-quickhelp-mode)


;; CONF MODE FOR INI / CONF / LIST
(add-to-list 'auto-mode-alist '("\\.flake8\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.ini\\'" . conf-mode ))
(add-to-list 'auto-mode-alist '("\\.list\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.pylintrc\\'" . conf-mode))


;; COUNSEL
;; USE TOGETHER WITH IVY-MODE
(counsel-mode 1)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)


;; DESKTOP-SAVE-MODE
(require 'desktop)
(setq desktop-modes-not-to-save '(dired-mode
				  Info-mode
				  info-lookup-mode))
(desktop-save-mode 1)


;; DIRENV-MODE
;; https://github.com/wbolster/emacs-direnv
(direnv-mode 1)
(setq direnv-use-faces-in-summary nil)


;; DOCKERFILE-MODE
(defun setup-dockerfile-mode ()
  "Settings for 'dockerfile-mode'."
  (company-mode 1)
  (flycheck-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("Dockerfile'" . dockerfile-mode))
(add-hook 'dockerfile-mode-hook #'setup-dockerfile-mode)


;; EDITORCONFIG EMACS
;; https://github.com/editorconfig/editorconfig-emacs
(defun setup-editorconfig-mode ()
  "Settings for 'editor-config-mode'."
  (interactive)
  (setq editorconfig-trim-whitespaces-mode 'ws-butler-mode))
(add-hook 'editorconfig-mode-hook #'setup-editorconfig-mode)
(editorconfig-mode 1)


;; ELECTRIC-PAIR-MODE
;; EMBEDDED
(require 'electric)
(setq electric-pair-pairs
      '((?\« . ?\»)
        (?\„ . ?\“)
        (?\( . ?\))))
(electric-pair-mode 1)

;; EMACS LISP MODE
;; IT IS NOT A ELISP-MODE!
(defun setup-emacs-lisp-mode ()
  "Settings for EMACS Lisp Mode."
  (interactive)
  (company-mode 1)
  (diff-hl-mode)
  (flycheck-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-hook 'emacs-lisp-mode-hook #'setup-emacs-lisp-mode)
(add-to-list 'auto-mode-alist '("\\.el\\'" . emacs-lisp-mode))


;; FLYCHECK
(setq flycheck-check-syntax-automatically '(mode-enabled save new-line)
      flycheck-locate-config-file-functions '(
					      flycheck-locate-config-file-by-path
					      flycheck-locate-config-file-ancestor-directories
					      flycheck-locate-config-file-home)
      flycheck-highlighting-mode 'lines
      flycheck-indication-mode 'left-margin
      flycheck-markdown-markdownlint-cli-config "~/.emacs.d/.markdownlintrc")


;; FLYCHECK-COLOR-MODE-LINE: highlight status line by flycheck state
;; https://github.com/flycheck/flycheck-color-mode-line
(with-eval-after-load "flycheck"
  (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))


;; FLYCHECK INDICATOR
(with-eval-after-load "flycheck"
  (add-hook 'flycheck-mode-hook 'flycheck-indicator-mode))


;; FLYCHECK-POS-TIP
;; https://github.com/flycheck/flycheck-pos-tip
(when (display-graphic-p)
  (with-eval-after-load "flycheck"
    (add-hook 'flycheck-mode-hook 'flycheck-pos-tip-mode)))


;; FORMAT ALL
;; https://github.com/lassik/emacs-format-all-the-code
(require 'format-all)
(global-set-key (kbd "<f12>") 'format-all-buffer)


;; GO-MODE
;; https://github.com/dominikh/go-mode.el
(defun setup-go-mode()
  "Settings for 'go-mode'."
  (interactive)
  (abbrev-mode 1)
  (buffer-face-mode 1)
  (diff-hl-mode 1)
  (flycheck-mode 1) ;; Turn on linters
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (visual-line-mode 1) ;; Highlight current line
  (whitespace-mode 1) ;; Show spaces, tabs and other
  (ws-butler-mode 1)) ;; Delete trailing spaces on changed lines)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
(add-hook 'go-mode-hook #'setup-go-mode)


;; HELM
(global-set-key (kbd "<f10>") 'helm-buffers-list)
(helm-mode 1)


;; HELM-COMPANY
(define-key company-active-map (kbd "C-:") 'helm-company)


;; IBUFFER
(require 'ibuffer)
(require 'ibuf-ext)
(defalias 'list-buffers 'ibuffer)
(defun setup-ibuffer ()
  "Settings for 'ibuffer-mode'."
  (interactive)
  (setq ibuffer-expert 1
        ibuffer-hidden-filter-groups (list "Helm" "*Internal*")
        ibuffer-hidden-filter-groups (list "Helm")
        ibuffer-maybe-show-regexps nil
        ibuffer-saved-filter-groups (quote
                                     (("default"
                                       ("Markdown"
                                        (mode . markdown-mode))
                                       ("Dired"
                                        (mode . dired-mode))
                                       ("Org"
                                        (mode . org-mode))
                                       ("YAML"
                                        (mode . yaml-mode))
                                       ("Protobuf"
                                        (mode . protobuf-mode))
                                       ("Lisp"
                                        (mode . emacs-lisp-mode))
                                       ("Python"
                                        (or
                                         (mode . python-mode)
                                         (mode . elpy-mode)
					 (mode . anaconda-mode)))
                                       ("Shell-script"
                                        (or
                                         (mode . shell-script-mode)
					 (mode . sh-mode)))
                                       ("Terraform"
                                        (or
                                         (mode . terraform-mode)))
				       ("SQL"
					(or
					 (mode . sql-mode)))
                                       ("Web"
                                        (or
					 (mode . js-mode)
					 (mode . js2-mode)
                                         (mode . web-mode)))
                                       ("Magit"
                                        (or
                                         (mode . magit-status-mode)
                                         (mode . magit-log-mode)
                                         (name . "^\\*magit")
                                         (name . "git-monitor")))
                                       ("Commands"
                                        (or
                                         (mode . shell-mode)
                                         (mode . eshell-mode)
                                         (mode . term-mode)
                                         (mode . compilation-mode)))
                                       ("Emacs"
                                        (or
                                         (name . "^\\*scratch\\*$")
                                         (name . "^\\*Messages\\*$")
                                         (name . "^\\*\\(Customize\\|Help\\)")
                                         (name . "\\*\\(Echo\\|Minibuf\\)"))))))
        ibuffer-show-empty-filter-groups nil ;; Do not show empty groups
        ibuffer-formats
        '((mark modified read-only " "
                (name 60 120 :left :elide)
                (size 10 10 :right)
                (mode 16 16 :left :elide)
                " " filename-and-process)
          (mark " "
                (name 60 60)
                " " filename))
        ibuffer-use-other-window nil)

  (hl-line-mode 1)
  (ibuffer-auto-mode 1)
  (ibuffer-switch-to-saved-filter-groups "default")
  )
(global-set-key (kbd "<f2>") 'ibuffer)
(add-to-list 'ibuffer-never-show-predicates "^\\*")
(add-hook 'ibuffer-mode-hook #'setup-ibuffer)


;; IVY-MODE
;; https://github.com/abo-abo/swiper#ivy
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)


;; IVY RICH
(ivy-rich-mode 1)


;; JSON-MODE
;; https://github.com/joshwnj/json-mode
(require 'json)
(defun setup-json-mode()
  "Settings for json-mode."
  (interactive)
  (company-mode 1)
  (flycheck-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.\\(?:json\\|bowerrc\\|jshintrc\\)\\'" . json-mode))
(add-hook 'json-mode-hook #'setup-json-mode)


;; LSP JEDI
(with-eval-after-load "lsp-mode"
  (add-to-list 'lsp-disabled-clients 'pyls)
  (add-to-list 'lsp-enabled-clients 'jedi))

;; MAGIT
;; https://magit.vc/
(require 'magit)
(with-eval-after-load "magit"
  (global-set-key (kbd "<f5>") 'magit-status)
  (global-set-key (kbd "<f6>") 'magit-checkout))


;; MARKDOWN MODE
;; https://github.com/jrblevin/markdown-mode
(require 'markdown-mode)
(defun setup-markdown-mode()
  "Settings for editing markdown documents."
  (interactive)
  (setq header-line-format " "
	left-margin-width 4
	line-spacing 3
	markdown-fontify-code-blocks-natively t
	right-margin-width 4
	word-wrap t)

  ;; Additional modes
  (abbrev-mode 1)
  (buffer-face-mode 1)
  (diff-hl-mode 1)
  (flycheck-mode 1) ;; Turn on linters
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (visual-line-mode 1) ;; Highlight current line
  (whitespace-mode 1) ;; Show spaces, tabs and other
  (ws-butler-mode 1) ;; Delete trailing spaces on changed lines
  (cond ;; Turn on spell-checking only in Linux
   ((string-equal system-type "gnu/linux")(flyspell-mode 1)))

  (set-face-attribute 'markdown-code-face        nil :family default-font-family)
  (set-face-attribute 'markdown-inline-code-face nil :family default-font-family))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\README\\'" . markdown-mode))
(add-hook 'markdown-mode-hook #'setup-markdown-mode)


;; MEGHANADA
;; https://github.com/mopemope/meghanada-emacs
(require 'meghanada)
(defun setup-meghanada-mode ()
  "Settings for 'meghanada-mode'."
  (interactive)
  (diff-hl-mode 1)
  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (visual-line-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.jar\\'" . meghanada-mode))
(add-hook 'java-mode-hook #'setup-meghanada-mode)



;; Turn off menu bar
(require 'menu-bar)
(menu-bar-mode 0)


;; MODE ICONS
;; https://github.com/ryuslash/mode-icons
(when (display-graphic-p)
  (mode-icons-mode 1))


;; MONOKAI THEME
(load-theme 'monokai t)
(require 'airline-themes)
(load-theme 'airline-doom-molokai t)


;; MULTIPLE CURSORS
(require 'multiple-cursors)
(global-set-key (kbd "C-C C-C") 'mc/edit-lines)


;; NLINUM MODE
;; https://elpa.gnu.org/packages/nlinum.html
(require 'nlinum)
(setq nlinum-format "%d\u0020\u2502") ;; │)


;; ORG-MODE
;; https://orgmode.org/
(defun setup-org-mode ()
  "Settings for 'org-mode'."
  (interactive)
  (setq truncate-lines nil
	left-margin-width 4
	right-margin-width 4
	word-wrap t))
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook #'setup-org-mode)


;; OVERWRITE-MODE
(overwrite-mode nil) ;; Disable overwrite mode


;; PHP-MODE
(straight-use-package 'php-mode)
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))


;; PROJECTILE-MODE
;; https://docs.projectile.mx/projectile/index.html
(require 'projectile)
(setq projectile-project-search-path '("~/repo/"))
(define-key projectile-mode-map (kbd "S-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(projectile-mode 1)


;; PROTOBUF-MODE
;; https://github.com/emacsmirror/protobuf-mode
(require 'protobuf-mode)
(defun setup-protobuf-mode ()
  "Settings for 'protobuf-mode'."
  (interactive)

  (company-mode 1)
  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-hook 'ptotobuf-mode-hook #'setup-protobuf-mode)
(add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))


;; PYTHON-MODE
(defun setup-python-mode ()
  "Settings for 'python-mode'."
  (interactive)
  (setq
   tab-width 4
   py-virtualenv-workon-home "~/.virtualenvs"
   python-shell-interpreter "python3"
   py-electric-comment-p t
   py-company-pycomplete-p t
   py-pylint-command-args "--max-line-length 120"
   )

  (anaconda-mode 1)
  (company-mode 1)
  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1)

  (define-key python-mode-map (kbd "M-.") 'jedi:goto-definition)
  (define-key python-mode-map (kbd "M-,") 'jedi:goto-definition-pop-marker)
  (define-key python-mode-map (kbd "M-/") 'jedi:show-doc)
  (define-key python-mode-map (kbd "M-?") 'helm-jedi-related-names)


  (with-eval-after-load "company"
    (unless (member 'company-jedi (car company-backends))
      (setq comp-back (car company-backends))
      (push 'company-jedi comp-back)
      (setq company-backends (list comp-back)))))
(add-hook 'python-mode-hook #'setup-python-mode)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))


;; RST-MODE
(defun setup-rst-mode ()
  "Settings for 'rst-mode'."
  (interactive)

  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-hook 'rst-mode-hook #'setup-rst-mode)
(add-to-list 'auto-mode-alist '("\\.rst\\'" . rst-mode))


;; RUBY-MODE
(straight-use-package 'ruby-mode)
(defun setup-ruby-mode ()
  "Settings for 'ruby-mode'."
  (interactive)

  (company-mode 1)
  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-hook 'ruby-mode-hook #'setup-ruby-mode)
(add-to-list 'auto-mode-alist '("\\.rb\\'" .ruby-mode))


;; PAREN-MODE
(show-paren-mode 1)


;; SAVE-PLACE-MODE
;; https://www.emacswiki.org/emacs/SavePlace
;; When you visit a file, point goes to the last place where it was when you
;; previously visited the same file.
(require 'saveplace)
(setq save-place-file (expand-file-name ".emacs-places" emacs-config-dir)
      save-place-forget-unreadable-files 1)
(save-place-mode 1)


;; SCALA MODE
;; https://github.com/hvesalai/emacs-scala-mode
(defun setup-scala-mode ()
  "Settings for 'scala-mode'."
  (interactive)
  (company-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-hook 'scala-mode-hook #'setup-scala-mode)
(add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode))
(add-to-list 'auto-mode-alist '("\\.sc\\'" . scala-mode))


;; SHELL-SCRIPT-MODE
(defun setup-shell-script-mode ()
  "Settings for 'shell-script-mode'."
  (interactive)
  (company-mode 1)
  (flycheck-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.sh\\'" . shell-script-mode))
(add-hook 'shell-script-mode #'setup-shell-script-mode)
(add-hook 'sh-mode-hook #'setup-shell-script-mode)


;; SQL MODE
(defun setup-sql-mode ()
  "Settings for SQL-mode."
  (interactive)
  (company-mode 1)
  (flycheck-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.sql\\'" . sql-mode))
(add-hook 'sql-mode-hook #'setup-sql-mode)


;; SWIPER
;; https://github.com/abo-abo/swiper}
(straight-use-package 'swiper)
(global-set-key (kbd "C-f") 'swiper-isearch)


;; TIDE-MODE
;; https://github.com/ananthakumaran/tide/
(defun setup-tide-mode ()
  "Settings for 'tide-mode'."
  (interactive)
  (company-mode 1)
  (eldoc-mode 1)
  (flycheck-mode 1)
  (tide-hl-identifier-mode 1)
  (tide-setup)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-hook 'tide-mode-hook #'setup-tide-mode)
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . tide-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tide-mode))


;; TERRAFORM-MODE
;; https://github.com/emacsorphanage/terraform-mode
(defun setup-terraform-mode ()
  "Settings for terraform-mode."
  (interactive)
  (setq flycheck-checker 'terraform)
  (company-mode 1)
  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.tf\\'" . terraform-mode))
(add-hook 'terraform-mode-hook #'setup-terraform-mode)


;; TREEMACS — awesome file manager (instead NeoTree)
;; https://github.com/Alexander-Miller/treemacs
(require 'treemacs)
(with-eval-after-load "treemacs"
  (defun treemacs-get-ignore-files (filename absolute-path)
    (or
     (string-equal filename ".emacs.desktop.lock")
     (string-equal filename "__pycache__")))
  (setq treemacs-width 25)
  (add-to-list 'treemacs-ignored-file-predicates #'treemacs-get-ignore-files)
  (define-key treemacs-mode-map (kbd "f") 'find-grep)
  (global-set-key (kbd "<f8>") 'treemacs)
  (global-set-key (kbd "C-<f8>") 'treemacs-switch-workspace))


;; TYPESCRIPT MODE
;; https://github.com/emacs-typescript/typescript.el
(require 'typescript-mode)
(with-eval-after-load "typescript-mode"
  (defun setup-typescript-mode ()
    "Settings for 'typescript-mode'."
    (interactive)
    (flycheck-mode 1)
    (nlinum-mode 1))
  (add-to-list 'auto-mode-alist '("\\.d.ts\\'" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
  (add-hook 'typescript-mode-hook #'setup-typescript-mode))


;; UNDO-TREE
(straight-use-package 'undo-tree)
(global-undo-tree-mode 1)


;; WEB-MODE
;; https://web-mode.org/
(straight-use-package 'web-mode)
(defun setup-web-mode()
  "Settings for web-mode."
  (setq web-mode-attr-indent-offset 4
        web-mode-css-indent-offset 2 ;; CSS
        web-mode-enable-block-face t
        web-mode-enable-css-colorization t
        web-mode-enable-current-element-highlight t
        web-mode-markup-indent-offset 2)

  (company-mode 1)
  (flycheck-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-hook 'web-mode-hook #'setup-web-mode)


;; WHICH-KEY MODE
;; https://github.com/justbur/emacs-which-key
(which-key-mode 1)


;; WHITESPACE MODE
;; https://www.emacswiki.org/emacs/WhiteSpace
(defun setup-whitespace-mode ()
  "Settings for 'whitespace-mode'."
  (interactive)
  (setq whitespace-display-mappings
        '(
          (space-mark   ?\    [?\xB7]     [?.]) ; space
          (space-mark   ?\xA0 [?\xA4]     [?_]) ; hard space
          (newline-mark ?\n   [?¶ ?\n]    [?$ ?\n]) ; end of line
          (tab-mark     ?\t   [?\xBB ?\t] [?\\ ?\t]) ; tab
          )
	;; Highlight lines with length bigger than 1000 chars)
	whitespace-line-column 1000)
  ;; Markdown-mode hack
  (set-face-attribute
   'whitespace-space nil
   :family default-font-family
   :foreground "#75715E")
  (set-face-attribute
   'whitespace-indentation nil
   :family default-font-family
   :foreground "#E6DB74"))
(add-hook 'whitespace-mode-hook #'setup-whitespace-mode)


;; YAML-MODE
;; https://github.com/yoshiki/yaml-mode
(defun setup-yaml-mode ()
  "Settings for yaml-mode."
  (interactive)

  (company-mode 1)
  (diff-hl-mode 1)
  (flycheck-mode 1)
  (hl-line-mode 1)
  (nlinum-mode 1)
  (rainbow-delimiters-mode 1)
  (whitespace-mode 1)
  (ws-butler-mode 1))
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))
(add-hook 'yaml-mode-hook #'setup-yaml-mode)

;;; init.el ends here
