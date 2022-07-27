;;; phafi.el --- Minor PHP mode for programming AFI projects

;; Copyright (C) 2012 Free Software Foundation, Inc.
;;
;; Author: Laurent Laffont <llaffont@afi-sa.fr>
;; Maintainer: Laurent Laffont <llaffont@afi-sa.fr>
;; Created: 6 Aug 2012
;; Version: 0.01
;; Keywords: languages, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;
;; Example of .emacs setup :
;;
;; (require 'php-mode)
;; (add-to-list 'auto-mode-alist  '("\\.php[34]?\\'\\|\\.phtml\\'" . php-mode))
;; (defun my-php-mode()
;; 	(autoload 'phafi-mode "phafi" "PHAFI mode")
;; 	(phafi-mode)
;;  (setq phafi-phpunit-config "~/path/to/myproject/tests/phpunit.xml")
;; )
;; (add-hook 'php-mode-hook 'my-php-mode)

;; "phpunit.xml path"

(setq phafi-phpunit-command "phpunit")
(setq phafi-mode-hook '(phafi-php-mode))
(setq phafi-debug-in-progress nil)

(defvar phafi-phpunit-profiling nil
  "Whether to run phpunit with xhprof for profiling or not")

(defun phafi-php-mode()
  (make-local-variable 'phafi-phpunit-config)

  (require 'geben)
  (require 'phpunit)
  (require 'gtags)

  (add-hook 'gtags-mode-hook 
	    (lambda()
	      (local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
	      (local-set-key (kbd "M-,") 'gtags-find-rtag)  ; reverse tag
	      (local-set-key (kbd "C-M-,") 'gtags-pop-stack); find tag if on call function or reverse tag if on function def
	      (local-set-key (kbd "C-.") 'gtags-find-tag-other-window) 

	      (setq gtags-ignore-case t)
	      (setq gtags-auto-update t)
	      (setq gtags-rootdir (phafi-root-dir))
	      )
	    )

  (add-hook 'gtags-select-mode-hook
	    (lambda()
	      (local-set-key (kbd "RET") 'gtags-select-tag) 
	      )
	    )

  
  (auto-complete-mode t)
  (subword-mode t)
  (gtags-mode t)

  (setq ag-highlight-search t)
  (setq ag-arguments (list "--smart-case" 
			   "--column"
			   "--ignore" "phonetix.txt" 
			   "--ignore" "TAGS" 
			   "--ignore-dir" "report" 
			   "--ignore" "coverage.xml" 
			   "--ignore-dir" "emacs" 
			   "--ignore-dir" "fichiers" 
			   "--ignore-dir" "jQuery" 
			   "--ignore-dir" "ckeditor"
			   "--ignore-dir" "Bootstrap"
			   "--ignore-dir" "Font-Awesome"
			   "--ignore" "jquery.mobile-1.1.0.min.js" 
			   "--ignore" "jquery.mobile-1.2.0.min.js"  
			   "--" ))

  (phafi-init-menu)

  (setq
   magit-diff-options '("-w")
   flymake-mode t
   compilation-error-regexp-alist  '(	("^\\(/.*\\):\\([0-9]+\\)$" 1 2)
					("^.* \\(/.*\\):\\([0-9]+\\)" 1 2)
					("PHP\s+[0-9]+\. [^/]* \\([^:]+\\):\\([0-9]+\\)" 1 2)
					("in \\(/.*\\) on line \\([0-9]+\\)" 1 2) )
   geben-pause-at-entry-line nil
   geben-show-breakpoints-debugging-only nil)
  (phafi-enable-bokeh-coding-style)
  (require 'auto-complete)
  (setq ac-sources '(ac-source-gtags ac-source-words-in-buffer ac-source-php-auto-yasnippets))
  )

(c-add-style
 "bokeh"
 '("php"
   (c-basic-offset . 2)
   (c-offsets-alist . ((case-label . +)
                       (topmost-intro-cont . (first c-lineup-cascaded-calls
                                                    php-lineup-arglist-intro))
                       (brace-list-intro . +)
                       (brace-list-entry . c-lineup-cascaded-calls)
                       (arglist-close . 0)
                       (arglist-intro . c-lineup-arglist-intro-after-paren)
                       (arglist-cont . c-lineup-arglist-intro-after-paren)
		       (arglist-cont-nonempty . c-lineup-arglist-intro-after-paren)
                       (knr-argdecl . [0])
                       (statement-cont . (first c-lineup-cascaded-calls +))))))

(defun phafi-enable-bokeh-coding-style ()
  "Makes php-mode use coding styles that are preferable for working with Bokeh."
  (interactive)
  (setq tab-width 2
        indent-tabs-mode nil
        fill-column 78
        show-trailing-whitespace t)
  (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)
  (c-set-style "bokeh"))

(defvar ac-source-gtags
  '((candidates . ac-gtags-candidate)
    (candidate-face . ac-gtags-candidate-face)
    (selection-face . ac-gtags-selection-face)
    (requires . 3))
  "Source for gtags.")

(defun phafi-update-gtags ()
  "create or update the gnu global tag file"
  (interactive)
  (if (not (= 0 (call-process "global" nil nil nil " -p"))) ; tagfile doesn't exist?
      (let ((olddir default-directory)
	    (topdir (read-directory-name  
		     "gtags: top of source tree:" default-directory)))
	(cd topdir)
	(phafi-delete-backup-files)
	(shell-command "gtags && echo 'created tagfile'")
	(cd olddir)) ; restore   
    (call-process-shell-command "global -u && echo 'updated tagfile'" nil "*Shell Command Output*" t)
    ))



(defun phafi-enable-autotest() 
  "When buffer is saved, run the tests"
  (interactive)
  (phafi-disable-autotest)
  (add-hook 'after-save-hook
	    (lambda ()
	      (if (and (equal (phafi-file-is-geben) nil) (equal phafi-debug-in-progress nil))
		  (if (phafi-file-is-test)
		      (phafi-phpunit-command-for-test)
		    (phafi-phpunit-command-for-file)))
	      )
	    )
  )


(defun phafi-phpunit-command-for-test()
  (if(phpunit-function-ap)
      (if(equal (phpunit-function-setup-ap) nil)
	  (phafi-run-phpunit-filtered-function nil)
	(phafi-run-phpunit-filtered-class nil))
    )
  )


(defun phafi-phpunit-command-for-file()
  (if (equal phafi-phpunit-command "phpunit")
      (setq phafi-phpunit-command 
	    (concat "phpunit -c " phafi-phpunit-config " --filter " (car(split-string (file-name-sans-extension (phafi-cur-file))))))
    )
  (phafi-compile-command phafi-phpunit-command)
  )


(defun phafi-file-is-geben()
  "File is geben ?"
  (search "geben" (file-name-sans-extension (phafi-cur-file)))
  )


(defun phafi-file-is-test()
  "Is file a test"
  (search "TEST" (upcase (file-name-sans-extension (phafi-cur-file))))
  )


(defun phafi-disable-autotest() 
  "See phafi-enable-autotest"
  (interactive)
  (setq after-save-hook nil)
  )


(defun phafi-stop-geben (buffer msg)
  (geben-end 'geben-dbgp-default-port)
  (jump-to-register 'g)
  (setq compilation-finish-functions '())
  (setq phafi-debug-in-progress nil)
  )


(defun phafi-compile-phpunit (&optional params filename debug testdox)
  (let
      ((command-filter (if params (concat " --filter " params) " "))
       (debug-mode (if debug (concat "XDEBUG_CONFIG='remote_port=" (number-to-string geben-dbgp-default-port) "' ") ""))
       (testdox-option (if testdox " --testdox " "")))

    (if debug (progn (geben 1)
		     (window-configuration-to-register 'g)
		     (add-to-list 'compilation-finish-functions 'phafi-stop-geben)
		     (setq phafi-debug-in-progress t)
		     )
      )

    (setq phafi-phpunit-command
	  (concat	debug-mode 
			"phpunit -c " 
			(phafi-selected-phpunit-config)
			" "
			command-filter 
			" " 
			filename 
			testdox-option))

    
    (if (buffer-modified-p) (save-buffer))
    (phafi-compile-command phafi-phpunit-command)
    )
  )


(defun phafi-compile-command(command)
  (setq compilation-buffer-name-function (lambda(mode) "*phpunit*"))
  (compilation-start command)
  )


(defun phafi-run-phpunit(debug-mode)
  "Run all phpunit tests"
  (interactive "P" )
  (phafi-compile-phpunit nil nil debug-mode)
  (rename-phpunit-buffer "*Running all phpunit tests*")
  )


(defun phafi-run-phpunit-stop-on-error(debug-mode)
  "Run all phpunit tests until an error occure"
  (interactive "P")
  (setq phafi-phpunit-command
	(concat debug-mode "phpunit -c " phafi-phpunit-config " --stop-on-error"))
  (compile phafi-phpunit-command)
  (rename-phpunit-buffer "*Running all phpunit tests until an error occure*")
  )


(defun phafi-run-phpunit-stop-on-failure(debug-mode)
  "Run all phpunit tests until a failure occure"
  (interactive "P")
  (setq phafi-phpunit-command
	(concat debug-mode "phpunit -c " phafi-phpunit-config " --stop-on-failure"))
  (compile phafi-phpunit-command)
  (rename-phpunit-buffer "*Running all phpunit tests until a failure occure*")
  )


(defun rename-phpunit-buffer (buffer-name)
  (set-buffer "*phpunit*") 
  (cond ((get-buffer buffer-name)
	 (kill-buffer buffer-name)))
  (rename-buffer buffer-name)
  )

(defun phafi-run-phpunit-filtered-file(debug-mode)
  "Run phpunit on this file / class"
  (interactive "P")
  (phafi-compile-phpunit
   (car (split-string (file-name-sans-extension (phafi-cur-file)) "Test")) nil
   debug-mode)
  )


(defun phafi-run-phpunit-filtered-class(debug-mode)
  "Run phpunit on this class"
  (interactive "P")
  (phafi-compile-phpunit (phpunit-class-ap) (concat  (phpunit-class-ap) " " buffer-file-name) debug-mode)
  )


(defun phafi-run-phpunit-filtered-function(debug-mode)
  "Run phpunit on this function"
  (interactive "P")

  (phafi-compile-phpunit (cdr (phpunit-function-ap)) (concat  (phpunit-class-ap) " " buffer-file-name) debug-mode)
  )


(defun phafi-run-phpunit-on-group(name)
  "Run all phpunit tests tagged by @group"
  (interactive "sGroup name: ")
  (setq phafi-phpunit-command
	(concat "phpunit -c " phafi-phpunit-config " --group " name))
  (compile phafi-phpunit-command)
  )

(defun phafi-toggle-phpunit-profiling ()
  (interactive)
  (setq phafi-phpunit-profiling (not phafi-phpunit-profiling))
  (message (concat "Profiling: " (if phafi-phpunit-profiling "ON" "OFF")))
  )


(defun phafi-run-last-phpunit-command()
  "Run last phpunit command"
  (interactive)
  (compile phafi-phpunit-command)
  )


(defun phafi-run-phpunit-filtered-custom(custom-filter debug testdox)
  "Prompt for a filter and run phpunit with it"
  (interactive (list (read-string "Enter PHPUnit filter: ")
		     (y-or-n-p "Debug ?: ")
		     (y-or-n-p "Testdox format ?: ")))
  (phafi-compile-phpunit custom-filter nil debug testdox)
  )


(defun phafi-cur-file ()
  "Return the filename (without directory) of the current buffer"
  (file-name-nondirectory (buffer-file-name (current-buffer)))
  )


(defun phafi-cur-dir ()
  "Return the directory of the current buffer"
  (file-name-directory (buffer-file-name (current-buffer)))
  )


(defun phafi-mode-dir ()
  "Return the directory where phafi-mode.el is"
  (file-name-directory (symbol-file 'phafi-php-mode))
  )


(defun phafi-find-tests()
  "Use PHPUnit coverage data to search for tests that cover current line"
  (interactive)
  (async-shell-command (concat
			(phafi-root-dir) "scripts/find_tests.php"
			" "
			(buffer-file-name (current-buffer) )
			" "
			(number-to-string (1+ (count-lines 1 (point))))
			)

		       )
  )


(defun phafi-selected-phpunit-config()
  (if phafi-phpunit-profiling
      (concat (phafi-root-dir) "tests/phpunit_with_profiling.xml")
    phafi-phpunit-config)
  )

(defun phafi-sql-patch(patch)
  "Force execution of db migration"
  (interactive (list (read-number "Enter patch number: ")))
  
  (async-shell-command (concat
			"cd "	(phafi-root-dir) ";"
			"php scripts/apply_patch.php "(number-to-string patch)
			))
  )


(defun phafi-root-dir()
  (concat
   (file-name-directory phafi-phpunit-config) "../")
  )


(defun phafi-install-dir() 
  (nth 1 (nreverse (split-string (expand-file-name (phafi-root-dir))  "/" )))
  )


(defun phafi-init-menu ()
  (interactive)

  (global-unset-key [menu-bar phafi])

  (define-key-after	global-map [menu-bar phafi]
    (cons "PHAFI" (make-sparse-keymap "phafi"))
    'tools )

  (define-key	global-map [menu-bar phafi find-tests]
    '("Find tests" . phafi-find-tests))

  ;; PHPUnit sub menus
  (define-key	global-map [menu-bar phafi phpunit]
    (cons "Run PHPUnit" (make-sparse-keymap "phpunit")))

  (define-key	global-map [menu-bar phafi phpunit function]
    '("function" . phafi-run-phpunit-filtered-function))

  (define-key	global-map [menu-bar phafi phpunit class]
    '("class" . phafi-run-phpunit-filtered-class))

  (define-key	global-map [menu-bar phafi phpunit file]
    '("file" . phafi-run-phpunit-filtered-file))

  (define-key	global-map [menu-bar phafi phpunit all]
    '("all" . phafi-run-phpunit))

  (define-key	global-map [menu-bar phafi phpunit last]
    '("last command" . phafi-run-last-phpunit-command))

  (define-key	global-map [menu-bar phafi phpunit debug]
    '("debug function" . phafi-debug-phpunit-function))
  )


(defun phafi-jump-to()
  (interactive)
  (funcall (popup-menu* (list
			 (popup-make-item "Models" :value 'phafi-jump-to-model)
			 (popup-make-item "Models tests" :value 'phafi-jump-to-model-tests)
			 (popup-make-item "Admin controllers" :value 'phafi-jump-to-admin-controller)
			 (popup-make-item "Admin controllers tests" :value 'phafi-jump-to-admin-controller-tests)
			 (popup-make-item "OPAC controllers" :value 'phafi-jump-to-opac-controller)
			 (popup-make-item "OPAC controllers tests" :value 'phafi-jump-to-opac-controller-tests)
			 (popup-make-item "Phone controllers" :value 'phafi-jump-to-phone-controller)
			 (popup-make-item "Phone controllers tests" :value 'phafi-jump-to-phone-controller)
			 (popup-make-item "Boxes" :value 'phafi-jump-to-opac-boxes)
			 )))
  )


(defun phafi-list-files (subdir nameregexp)
  (let ((directory (concat (phafi-root-dir) subdir)))
    (directory-files directory '() nameregexp)
    )
  )


(defun phafi-jump-to-model()
  (interactive)
  (phafi-select-file-and-switch "library/Class" ".php$")
  )


(defun phafi-jump-to-model-tests()
  (interactive)
  (phafi-select-file-and-switch "tests/library/Class" ".php$")
  )


(defun phafi-jump-to-admin-controller()
  (interactive)
  (phafi-select-file-and-switch "application/modules/admin/controllers" ".php$")
  )


(defun phafi-jump-to-admin-controller-tests()
  (interactive)
  (phafi-select-file-and-switch "tests/application/modules/admin/controllers" ".php$")
  )


(defun phafi-jump-to-opac-controller()
  (interactive)
  (phafi-select-file-and-switch "application/modules/opac/controllers" ".php$")
  )


(defun phafi-jump-to-opac-controller-tests()
  (interactive)
  (phafi-select-file-and-switch "tests/application/modules/opac/controllers" ".php$")
  )


(defun phafi-jump-to-phone-controller()
  (interactive)
  (phafi-select-file-and-switch "application/modules/telephone/controllers" ".php$")
  )


(defun phafi-jump-to-phone-controller-tests()
  (interactive)
  (phafi-select-file-and-switch "tests/application/modules/telephone/controllers" ".php$")
  )


(defun phafi-jump-to-opac-boxes()
  (interactive)
  (phafi-select-file-and-switch "library/ZendAfi/View/Helper/Accueil" ".php$")
  )


(defun phafi-select-file-and-switch(subdir nameregexp)
  (let
      ((filepath  (find-file (phafi-select-file subdir nameregexp)))
       )
    (switch-to-buffer filepath)
    )
  )


(defun phafi-select-file (subdir nameregexp)
  (let ((directory (concat (phafi-root-dir) subdir)))
    (concat directory "/" (popup-menu* (directory-files directory '() nameregexp)))
    )
  )


(defun phafi-debug-phpunit-function()
  "Run phpunit on this function with debugger activated"
  (interactive)
  (phafi-run-phpunit-filtered-function t)
  )


(defun phafi-strftime(start end)
  "Interprets region as a timestamp and converts into human date"
  (interactive "r")
  (let ((selected-text (buffer-substring start end)))
    (geben-eval-expression (concat "strftime('%Y-%m-%d %H:%M:%S', " selected-text " )")))
  )


(defun phafi-eval-region(start end)
  "Eval current region in geben"
  (interactive "r")
  (let ((selected-text (buffer-substring start end)))
    (geben-eval-expression selected-text))
  )


(defun phafi-describe-function ()
  "Display the full documentation of FUNCTION, using pman"
  (interactive)
  (let* ((str (shell-command-to-string (concat "pman " (current-word))))
         (str (replace-regexp-in-string "\\\\" "" str)))
    (with-output-to-temp-buffer "*Pman*"
      (princ str))
    (balance-windows-area)))


(define-minor-mode phafi-mode
  "Toggle AFI-OPAC  mode."
  :lighter " phafi"
  :keymap
  '(("\C-crf" . phafi-run-phpunit-filtered-function)
    ("\C-crc" . phafi-run-phpunit-filtered-class)
    ("\C-cra" . phafi-run-phpunit-filtered-file)
    ("\C-crm" . phafi-run-phpunit-filtered-custom)
    ("\C-crl" . phafi-run-last-phpunit-command)
    ("\C-crp" . phafi-run-phpunit)
    ("\C-crg" . phafi-run-phpunit-on-group)
    ("\C-cse" . phafi-run-phpunit-stop-on-error)
    ("\C-csf" . phafi-run-phpunit-stop-on-failure)
    ("\C-crd" . phafi-debug-phpunit-function)
    ("\C-cp" . phafi-toggle-phpunit-profiling)
    ("\C-ce" . phafi-eval-region)
    ("\C-cd" . phafi-describe-function)
    ("\C-ct" . phafi-find-tests)
    ("\C-cj" . phafi-jump-to)
    ("\C-c\C-s" . phafi-select-db))
  :after-hook 'phafi-mode-hook)


(provide 'phafi-mode)



(defun ack (command-args)
  (interactive
   (let ((ack-command 
	  (if (file-exists-p "/usr/bin/ack-grep") "ack-grep "  "ack ")))
     (list (read-shell-command "Run ack (like this): "
                               ack-command
                               'ack-history))))
  (let ((compilation-disable-input t))
    (compilation-start (concat command-args " < " null-device)
                       'grep-mode)))


(defun phafi-autofocus-start (tix)
  (interactive (list (read-number "Enter tix number: ")))
  (async-shell-command (concat
			"cd "	(phafi-root-dir) ";"
			"autofocus start "(number-to-string tix)
			))
  )


(defun phafi-autofocus-version ()
  (interactive)
  (async-shell-command (concat
			"cd "	(phafi-root-dir) ";"
			"autofocus version"
			))
  )


(defun phafi-autofocus-miniversion ()
  (interactive)
  (async-shell-command (concat
			"cd "	(phafi-root-dir) ";"
			"autofocus miniversion"
			))
  )


(defun phafi-autofocus-digital (folder)
  (interactive (list (read-string "Folder name: ")))
  (async-shell-command (concat
			"cd "	(phafi-root-dir) ";"
			"autofocus digital " folder
			))
  )

(defun phafi-autofocus-theme (folder)
  (interactive (list (read-string "Folder name: ")))
  (async-shell-command (concat
			"cd "	(phafi-root-dir) ";"
			"autofocus theme " folder
			))
  )


(defun phafi-select-db (client)
  (interactive (list (completing-read "DB: " (process-lines "show_db"))))
  (async-shell-command
   (concat "php ./scripts/select_db.php " client))
  )


(defun phafi-replace-in-file(from to filename) 
  (save-excursion
    (find-file filename)
    (goto-char (point-min))
    (replace-regexp from to)
    (save-buffer)
    (kill-buffer (current-buffer))
    )
  )


(defun phafi-console ()
  "Opens a bokeh console"
  (interactive)
  (let ((buffer (generate-new-buffer "Bokeh console")))
    (async-shell-command (concat
			  "cd "	(phafi-root-dir) ";"
			  "php -d \"auto_prepend_file=console.php\" -d \"cli.prompt='bokeh> '\" -a")
			 buffer)
    (switch-to-buffer-other-frame buffer)
    )
  )


(defun phafi-delete-backup-files ()
  "find and delete files with ending by ~ and empty folders"
  (interactive)
  (shell-command (concat
		  "cd " (phafi-root-dir) ";"
		  "find . -name '*~' -delete;"
		  "find . -type d -empty -delete"))
  )


(defun phafi-delete-temp-files ()
  "find and delete files in temp"
  (interactive)
  (shell-command (concat
		  "cd " (phafi-root-dir) "/temp;"
		  "find . -type f -not -iwholename '*.gitignore' -name '*' -delete;"))
  )
