;;; init-local -- local config
;;; Commentary:
;;; Code:
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
;; Straight configs
(setq straight-vc-git-default-clone-depth 1)
(set-face-attribute 'default nil
                    :height 130)
(load-theme 'sanityinc-tomorrow-day t)

(defun get-pass-from-auth (&optional host user)
  "Lookup api key in the auth source.
By default, \"openai.com\" is used as HOST and \"apikey\" as USER."
  (if-let ((secret (plist-get (car (auth-source-search
                                    :host (or host "google.com")
                                    :user (or user "gemini")))
                              :secret)))
      (if (functionp secret) (funcall secret) secret)
    (user-error "No `gptel-api-key' found in the auth source")))

(require 'init-meow)
(straight-use-package 'telega)
(setq telega-use-images nil)
(with-eval-after-load 'telega
  (define-key telega-chat-mode-map (kbd "C-c o") 'telega-sticker-choose-favorite-or-recent)
  (set-face-attribute 'telega-msg-heading nil
                      :background nil)
  (setq telega-date-format-alist '((today . "")
                                   (this-week . "")
                                   (old . "")
                                   (date  . "")
                                   (date-time . "")
                                   (date-long . "")
                                   (date-break-bar . "")
                                   (time . "")))
  (setq telega-symbol-checkmark "")
  (setq telega-symbol-heavy-checkmark "")
  )

(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")
(require 'mu4e)
(setq mail-user-agent 'mu4e-user-agent)
(setq mu4e-maildir (expand-file-name "~/Maildir"))
(setq mu4e-drafts-folder "/草稿箱")
(setq mu4e-sent-folder "/已发送")
(setq mu4e-trash-folder "/垃圾邮件")
;; Fetch mail by offlineimap
(setq mu4e-get-mail-command "offlineimap")
;; Fetch mail in 60 sec interval
(setq mu4e-update-interval 60)
(require 'auth-source);; probably not necessary
(setq auth-sources '("~/.authinfo"))
(setq message-send-mail-function 'smtpmail-send-it)
(setq user-mail-address "mengzixian@js.chinamobile.com")
(setq user-full-name "孟子贤")
(setq smtpmail-smtp-user "mengzixian@js.chinamobile.com"
      smtpmail-smtp-server "smtp.js.chinamobile.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type 'ssl)
(add-to-list 'meow-mode-state-list '(mu4e-view-mode . motion))
(add-to-list 'meow-mode-state-list '(mu4e-main-mode . motion))
(mu4e-modeline-mode 1)
(require 'eglot)
(straight-use-package '(pet :host github :repo "wyuenho/emacs-pet"))
(add-hook 'python-base-mode-hook 'pet-mode -10)
(add-hook 'python-mode-hook
          (lambda ()
            (setq-local python-shell-interpreter (pet-executable-find "python")
                        python-shell-virtualenv-root (pet-virtualenv-root))
            (pet-flycheck-setup)))
(add-hook 'python-mode-hook #'eglot-ensure)

(use-package rime
  :straight (rime :type git
                  :host github
                  :repo "DogLooksGood/emacs-rime"
                  :files ("*.el" "Makefile" "lib.c"))
  :custom
  (default-input-method "rime")
  :bind
  ("C-M-;" . rime-force-enable)
  :config
  (setq rime-show-candidate 'posframe)
  (setq rime-disable-predicates
        '(meow-normal-mode-p
          rime-predicate-after-alphabet-char-p
          rime-predicate-prog-in-code-p
          rime-predicate-current-uppercase-letter-p)))

(straight-use-package 'web-mode)
(define-derived-mode genehack-vue-mode web-mode "ghVue"
  "A major mode derived from web-mode, for editing .vue files with LSP support.")
(add-to-list 'auto-mode-alist '("\\.vue\\'" . genehack-vue-mode))
(with-eval-after-load 'eglot
;;  (add-hook 'genehack-vue-mode-hook 'eglot-ensure)
  (add-to-list 'eglot-server-programs '(genehack-vue-mode "vls")))

(set-face-attribute 'mmm-default-submode-face nil
                    :background nil)
(setq ispell-alternate-dictionary (expand-file-name "~/.emacs.d/english-words.txt"))

(use-package python-black
  :straight t
  :demand t
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim))

(use-package aidermacs
  :straight (:host github :repo "MatthewZMD/aidermacs" :files ("*.el"))
  :config
  (setq aidermacs-default-model "deepseek/deepseek-chat")
  (global-set-key (kbd "C-c a") 'aidermacs-transient-menu)
                                        ; Ensure emacs can access *_API_KEY through .bashrc or setenv
  (setenv "DEEPSEEK_API_KEY" (get-pass-from-auth "deepseek.com" "deepseek"))
  (setenv "OPENAI_API_BASE" "https://api.lkeap.cloud.tencent.com/v1")
  (setenv "OPENAI_API_KEY" (get-pass-from-auth "api.lkeap.cloud.tencent.com" "openai"))
                                        ; See the Configuration section below
  (setq aidermacs-auto-commits t))

(setenv "XAPIAN_CJK_NGRAM" "1")

(with-eval-after-load 'flycheck
  ;;  (setq flycheck-python-pylint-executable "/usr/bin/pylint")
  ;;  (setq flycheck-checkers (delete 'python-pyright flycheck-checkers))
  ;;  (add-to-list 'flycheck-disabled-checkers 'python-pyright)
  )

(with-eval-after-load 'eldoc
  (setq eldoc-echo-area-use-multiline-p nil))

(straight-use-package 'gptel)
(setq gptel-model 'deepseek-chat
      gptel-backend (gptel-make-deepseek "Deepseek"
                      :stream t
                      :key (get-pass-from-auth "deepseek.com" "deepseek"))
      gptel-use-curl nil)



(straight-use-package 'minuet)
(use-package minuet
  :bind
  (("M-y" . #'minuet-complete-with-minibuffer) ;; use minibuffer for completion
   ("M-i" . #'minuet-show-suggestion) ;; use overlay for completion
   ("C-c m" . #'minuet-configure-provider)
   :map minuet-active-mode-map
   ;; These keymaps activate only when a minuet suggestion is displayed in the current buffer
   ("M-p" . #'minuet-previous-suggestion) ;; invoke completion or cycle to next completion
   ("M-n" . #'minuet-next-suggestion) ;; invoke completion or cycle to previous completion
   ("M-A" . #'minuet-accept-suggestion) ;; accept whole completion
   ;; Accept the first line of completion, or N lines with a numeric-prefix:
   ;; e.g. C-u 2 M-a will accepts 2 lines of completion.
   ("M-a" . #'minuet-accept-suggestion-line)
   ("M-e" . #'minuet-dismiss-suggestion))

  :init
  ;; if you want to enable auto suggestion.
  ;; Note that you can manually invoke completions without enable minuet-auto-suggestion-mode
  (add-hook 'prog-mode-hook #'minuet-auto-suggestion-mode)

  :config
  ;; You can use M-x minuet-configure-provider to interactively configure provider and model
  (setq minuet-provider 'gemini)
  (setenv "GEMINI_API_KEY" (get-pass-from-auth "google.com" "gemini")))

;; For Evil users: When defining `minuet-ative-mode-map` in insert
;; or normal states, the following one-liner is required.

;; (add-hook 'minuet-active-mode-hook #'evil-normalize-keymaps)

;; This is *not* necessary when defining `minuet-active-mode-map`.

;; To minimize frequent overhead, it is recommended to avoid adding
;; `evil-normalize-keymaps` to `minuet-active-mode-hook`. Instead,
;; bind keybindings directly within `minuet-active-mode-map` using
;; standard Emacs key sequences, such as `M-xxx`. This approach should
;; not conflict with Evil's keybindings, as Evil primarily avoids
;; using `M-xxx` bindings.
(straight-use-package 'embark)

(use-package org-agenda
  :custom
  (org-agenda-files '("~/org/todo.org"))
  :bind
  ("C-c h" . org-agenda))


(provide 'init-local)
;;; init-local.el ends here
