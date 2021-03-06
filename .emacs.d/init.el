;;---------------------------------------------------
;;
;; El-get設定
;;---------------------------------------------------

;; load-path で ~/.emacs.d とか書かなくてよくなる
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;; el-get
(add-to-list 'load-path (locate-user-emacs-file "el-get"))
(require 'el-get)
;; el-getでダウンロードしたパッケージは ~/.emacs.d/ に入るようにする

(setq el-get-dir (locate-user-emacs-file "elisp"))

;;---------------------------------------------------
;;
;; Emacs全般の設定
;;---------------------------------------------------
;; 起動時に出てくるメッセージを消す
(setq inhibit-startup-message t)

;; 行、列の表示
(line-number-mode t)
(column-number-mode t)
(global-linum-mode t)

;; C-h to Backspace
(global-set-key "\C-h" 'delete-backward-char)

;; C-c C-c to comment-or-uncomment-region
(global-set-key "\C-c\C-c" 'comment-or-uncomment-region)

;; タブ幅を設定
(setq-default tab-width 4 indent-tabs-mode nil)

;; ビープを無効に
(setq ring-bell-function 'ignore)

;; 折り返し
(setq truncate-partial-width-windows nil)

;; シンボリックリンクのリンク先を直接開く
(setq vc-follow-symlinks t)

;; ファイルの自動リロード
(global-auto-revert-mode 1)

;; ツールバー・メニューバーの非表示
(menu-bar-mode -1)
(tool-bar-mode -1)

;; スクロールを良い感じにする
(defun scroll-down-with-lines ()
  "" (interactive) (scroll-down 3))
(defun scroll-up-with-lines ()
  "" (interactive) (scroll-up 3))
(global-set-key [wheel-up] 'scroll-down-with-lines)
(global-set-key [wheel-down] 'scroll-up-with-lines)
(global-set-key [double-wheel-up] 'scroll-down-with-lines)
(global-set-key [double-wheel-down] 'scroll-up-with-lines)
(global-set-key [triple-wheel-up] 'scroll-down-with-lines)
(global-set-key [triple-wheel-down] 'scroll-up-with-lines)

;; 保存するタイミングでdelete-trailing-whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; リージョン削除
(delete-selection-mode t)

;;----------------------------------------------------
;;
;; Text and Font
;;----------------------------------------------------
;; 背景色と文字色
(setq default-frame-alist
      (append
       '((foreground-color . "ivory")
         (background-color . "black")
         (cursor-color . "deep pink")
         (alpha . (80 55 nil nil)))
       default-frame-alist))

;; フォントを指定
(set-face-attribute 'default nil
                    :family "Ricty"
                    :height 140)

;;---------------------------------------------------
;;
;; 機能拡張
;;---------------------------------------------------
;;画面を 2 分割したときの 上下を入れ替える swap screen
(defun swap-screen()
  "Swap two screen,leaving cursor at current window."
  (interactive)
  (let ((thiswin (selected-window))
        (nextbuf (window-buffer (next-window))))
    (set-window-buffer (next-window) (window-buffer))
    (set-window-buffer thiswin nextbuf)))
(defun swap-screen-with-cursor()
  "Swap two screen,with cursor in same buffer."
  (interactive)
  (let ((thiswin (selected-window))
        (thisbuf (window-buffer)))
    (other-window 1)
    (set-window-buffer thiswin (window-buffer))
    (set-window-buffer (selected-window) thisbuf)))
(global-set-key [f2] 'swap-screen)
(global-set-key [S-f2] 'swap-screen-with-cursor)

;; 対応する括弧をハイライト
(show-paren-mode t)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face "gray15")
(set-face-foreground 'show-paren-match-face "white")

;; 矢印キーで画面移動
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <down>")  'windmove-down)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <right>") 'windmove-right)

(put 'upcase-region 'disabled nil)

;;---------------------------------------------------
;;
;; el-getによるPackage管理
;;---------------------------------------------------
;; google transelate
(el-get-bundle google-translate)
(require 'google-translate-default-ui)
(defvar google-translate-english-chars "[:ascii:]’“”–"
  "これらの文字が含まれているときは英語とみなす")
(defun google-translate-enja-or-jaen (&optional string)
  "regionか、現在のセンテンスを言語自動判別でGoogle翻訳する。"
  (interactive)
  (setq string
        (cond ((stringp string) string)
              (current-prefix-arg
               (read-string "Google Translate: "))
              ((use-region-p)
               (buffer-substring (region-beginning) (region-end)))
              (t
               (save-excursion
                 (let (s)
                   (forward-char 1)
                   (backward-sentence)
                   (setq s (point))
                   (forward-sentence)
                   (buffer-substring s (point)))))))
  (let* ((asciip (string-match
                  (format "\\`[%s]+\\'" google-translate-english-chars)
                  string)))
    (run-at-time 0.1 nil 'deactivate-mark)
    (google-translate-translate
     (if asciip "en" "ja")
     (if asciip "ja" "en")
     string)))
(global-set-key (kbd "C-c t") 'google-translate-enja-or-jaen)


;; anzu設定
(el-get-bundle anzu)
(global-anzu-mode +1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(anzu-deactivate-region t)
 '(anzu-mode-lighter "")
 '(anzu-search-threshold 1000)
 '(safe-local-variable-values
   (quote
    ((eval ignore-errors "Write-contents-functions is a buffer-local alternative to before-save-hook"
           (add-hook
            (quote write-contents-functions)
            (lambda nil
              (delete-trailing-whitespace)
              nil))
           (require
            (quote whitespace))
           "Sometimes the mode needs to be toggled off and on."
           (whitespace-mode 0)
           (whitespace-mode 1))
     (whitespace-line-column . 80)
     (whitespace-style face tabs trailing lines-tail)))))

;; autocomplete
(el-get-bundle auto-complete)
(ac-config-default)

;;yasnippet設定
(el-get-bundle yasnippet)
(yas-global-mode 1)

;; ruby-mode
;; (el-get-bundle enh-ruby-mode)
(el-get-bundle ruby-block)
(el-get-bundle ruby-electric)
(add-to-list 'auto-mode-alist '("\\.rb$latex " . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
;; 括弧の後のインデントが深くなるのを防ぐ
(setq ruby-deep-indent-paren-style nil)
;; マジックコメントの自動挿入を停止
(setq ruby-insert-encoding-magic-comment nil)
(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
(setq ruby-electric-expand-delimiters-list nil)
;; ruby-block.el --- highlight matching block
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)

;; rhtml-mode
(el-get-bundle rhtml-mode)
(add-to-list 'auto-mode-alist '("\\.erb$" . rhtml-mode))

;; haml-mode
(el-get-bundle haml-mode)

;; haskell-mode
(el-get-bundle haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.lhs$" . literate-haskell-mode))
(add-to-list 'auto-mode-alist '("\\.cabal\\'" . haskell-cabal-mode))

;; yaml-mode
(el-get-bundle yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;; coffee-mode
(el-get-bundle coffee-mode)
(defun coffee-custom ()
  "coffee-mode-hook"
  (and (set (make-local-variable 'tab-width) 2)
       (set (make-local-variable 'coffee-tab-width) 2))
  )
(add-hook 'coffee-mode-hook
  '(lambda() (coffee-custom)))

;; json-mode
(el-get-bundle json-mode)
(add-hook 'json-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

;; git
(el-get-bundle git-gutter)
(el-get-bundle magit)

;; twittering mode
(el-get-bundle twittering-mode)
(setq twittering-use-master-password t)

;;バックアップファイルの作成場所をシステムのTempにする
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
;;オートセーブファイルの作成場所をシステムのTempディレクトリに変更する
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; quickrun
(el-get-bundle quickrun)
(global-set-key (kbd "<f5>") 'quickrun)
(global-set-key (kbd "C-<f5>") 'quickrun-with-arg)
(global-set-key (kbd "M-<f5>") 'quickrun-compile-only)

;; popwin
(el-get-bundle popwin)
(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)
(setq popwin:popup-window-position 'bottom)
(push '("*quickrun*") popwin:special-display-config)
(push '("*Google Translate*") popwin:special-display-config)

;; yatex-mode
;; run yatex mode when open .tex file
(el-get-bundle yatex)
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(setq YaTeX-prefix "\C-t")
(setq tex-command "platex")
(setq dviprint-command-format "dvipdfmx %s")
;; use utf-8 on yatex mode
(setq YaTeX-kanji-code 4)
