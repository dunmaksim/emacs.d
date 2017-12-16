;;; web.el --- summary
;;; Commentary:
;;; Settings for web-development

;;; Code:

(use-package emmet-mode
  :mode
  ("\\.html\\'" . emmet-mode)
  :bind
  ("C-j" . emmet-expand-line))

(use-package web-mode
  :commands web-mode
  :mode (("\\.phtml\\'" . web-mode)
	 ("\\.html\\'" . web-mode))
  :custom ((web-mode-markup-indent-offset 2)
	   (web-mode-css-indent-offset 2)
	   (web-mode-enable-css-colorization t)))

(use-package web-beautify
  :hook ((js2-mode-hook . (lambda () (add-hook 'before-save-hook 'web-beautify-js-buffer t t)))
	 (json-mode-hook . (lambda () (add-hook 'before-save-hook 'web-beautify-js-buffer t t)))
	 (web-mode-hook . (lambda () (add-hook 'before-save-hook 'web-beautify-html-buffer t t)))
	 (css-mode-hook . (lambda () (add-hook 'before-save-hook 'web-beautify-css-buffer t t))))
  :ensure t)

(use-package css-mode
  :mode "\\.css\\'")

;; (eval-after-load 'js2-mode '(add-hook 'js2-mode-hook (lambda () (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))
;; (eval-after-load 'json-mode '(add-hook 'json-mode-hook (lambda () (add-hook 'before-save-hook 'web-beautify-js-buffer t t))))
;; (eval-after-load 'web-mode-hook '(add-hook 'web-mode-hook (lambda () (add-hook 'before-save-hook 'web-beautify-html-buffer t t))))
;; (eval-after-load 'css-mode '(add-hook 'css-mode-hook (lambda () (add-hook 'before-save-hook 'web-beautify-css-buffer t t))))

;;; web.el ends here
