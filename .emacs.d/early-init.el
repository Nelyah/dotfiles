;; -*- lexical-binding: t; -*-

;; Defer package.el — we call package-initialize explicitly in init.el
(setq package-enable-at-startup nil)

;; Strip GUI chrome before frame draws (prevents flash)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Don't resize frame when font/face changes
(setq frame-inhibit-implied-resize t)

;; Silence native-comp warnings
(setq native-comp-async-report-warnings-errors 'silent)
