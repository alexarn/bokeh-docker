(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))


(use-package php-mode)
(use-package geben
  :load-path "lisp/geben-1.1.2")
(use-package ag)
(use-package auto-complete)

(use-package magit)
(global-set-key (kbd "C-x g") 'magit-status)

(global-set-key [f8] 'next-error)
(global-set-key [f9] 'geben-end)

(defalias 'yes-or-no-p 'y-or-n-p) 
(use-package rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(use-package yasnippet)

(custom-set-variables
 '(menu-bar-mode nil)
 '(show-paren-mode t)
 '(geben-pause-at-entry-line nil)
 '(size-indication-mode t)
 '(column-number-mode t)
 )


(load-theme 'tango-dark)


(setq userpath (concat  "/home/" user-login-name "/dev/bokeh" ))
(add-to-list 'load-path "~/.emacs.d/lisp")

(setq phafi-phpunit-config (concat userpath "/tests/phpunit.xml"))

(add-hook 'php-mode-hook
          '(lambda ()
	    (require 'phafi-mode)
	    (phafi-mode t)
	    (add-hook 'phafi-mode-hook 'my-phafi-mode)
	    ))

(defun my-phafi-mode()
  (if (string-match "eco/" (buffer-file-name))
      (setq phafi-phpunit-config (concat userpath "/tests/phpunit_eco.xml"))
    
    (if (string-match "cosmozend/" (buffer-file-name))
	(setq phafi-phpunit-config (concat userpath "/cosmogramme/cosmozend/tests/phpunit.xml"))

      (if (string-match "/websvc/" (buffer-file-name))
	  (setq phafi-phpunit-config (concat userpath "/websvc/tests/phpunit.xml"))

	(if (string-match "websvc/" (buffer-file-name))
	    (setq phafi-phpunit-config "~/htdocs/websvc/tests/phpunit.xml")

	  (if (string-match "storm/" (buffer-file-name))
	      (setq phafi-phpunit-config  (concat userpath "/library/storm/tests/phpunit.xml"))

	    (if (and
		 (not (string-match "/library/Class" (buffer-file-name)))
		 (string-match "/cosmogramme" (buffer-file-name)))
		(setq phafi-phpunit-config (concat userpath "/cosmogramme/tests/phpunit.xml"))

	      (setq phafi-phpunit-config (concat userpath "/tests/phpunit.xml")))
	    )
	  )
	)
      )
    )
  )


(require 'yasnippet)
(add-to-list 'yas-snippet-dirs (concat userpath "/scripts/emacs/yasnippet/snippets/text-mode/"))
(yas-global-mode 1)

(defun dump_db(dbname)
  (interactive (list (read-string "DB name: ")))
  (async-shell-command
   (concat "bash dump_db " dbname)))

(use-package ibuffer-sidebar)
(use-package ibuffer-sidebar
  :bind (("C-x C-b" . ibuffer-sidebar-toggle-sidebar))
  :ensure nil
  :commands (ibuffer-sidebar-toggle-sidebar))

(require 'winner)
(winner-mode)

(global-set-key (kbd "C-c f") 'next-multiframe-window)
(global-set-key (kbd "C-c b") 'previous-multiframe-window)

(require 'uniquify)
(load-file ".emacs.d/custom.el")
