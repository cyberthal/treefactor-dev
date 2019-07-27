;; * treesort.el
;; * code
;; ** throw

;; *** config DONE

;; **** don't search invisible text in dired DONE

(add-hook 'dired-mode-hook
          (lambda ()
            (make-local-variable 'search-invisible)
            (setq search-invisible nil)))
;; *** main defun DONE

(defun ts-throw ()
  "Throw text or dired item to a target."
  (interactive)

  (let ((ts-window-home (selected-window))
        (ts-mode-home major-mode)
        (ts-window-other (next-window))
        )

    ;; Determines whether object is file or text.
    (if (eq ts-mode-home 'dired-mode)
        (ts-throw-file)
      (ts-throw-text))
    )
  )
;; *** flow control dispatcher TODO

;; **** throw file DONE

;; ***** throw file TODO

(defun ts-throw-file ()

  (other-window 1)

  (let ((ts-buffer-search (buffer-name))
        )

    (let* ((ts-searched-file-path (ts-searched-file-path))
          (ts-destination-file-path (concat ts-searched-file-path "/0-Inbox"))
          )

      (mkdir ts-destination-file-path 1)
      (find-file ts-destination-file-path)

      (other-window -1) ; select-window might not work here cuz DEFER
      (dired-do-rename) ; this func is interactive with user input

      (select-window ts-window-other 1)
      (switch-to-buffer ts-buffer-search 1) ; interactive func steals window back.
      (other-window -1) ; returns user to his original window
      )
    )
  )

;; ***** to dired TODO
;; **** throw text
;; ***** snort type
;; ******  flow control dispatcher TODO

(defun ts-snort-text-org ()
     ""
     (if (org-at-heading-p) (ts-snort-org-heading)
            (ts-snort-line))
     )

(defun ts-snort-text-outshine ()
     ""
     (if (outline-on-heading-p) (ts-snort-outshine-heading)
            (ts-snort-line))
     )

(defun ts-snort-text-outline ()
     ""
     (if (outline-on-heading-p) (ts-snort-outline-heading)
            (ts-snort-line))
     )
;; ******  snort org heading DONE

(defun ts-snort-org-heading ()
     ""
     (org-save-outline-visibility
                (org-narrow-to-subtree)
              (ts-snort-visible)
              )
     )
;; ***** destination = file or directory?

(defun ts-throw-text ()
  ""
  (other-window 1)
  (let ((ts-mode-minor minor-mode-list)
        (ts-searched-file-path (ts-searched-file-path))
        )
    (other-window -1)


    (if (file-directory-p ts-searched-file-path)
        (ts-throw-text-to-dir)
      (ts-throw-text-to-file))
    )
  )
;; ****** throw text, destination = dir DONE

(defun ts-throw-text-to-dir ()
  "Insert text to Inbox.org"

  (select-window ts-window-home)
  (ts-create-inbox-org)
  (ts-insert-to-end-of-buffer)
  (switch-to-buffer ts-buffer-target-1)
  (select-window ts-window-home)
  )
;; ****** throw text, destination = file DONE

(defun ts-throw-text-to-file ()
  "Yank text to target file."

  (goto-char (point-min))

  ;; Put point either before first top-level heading or at end of buffer.
  ;; Normally one wants to yank to the end of the buffer.
  ;; But if it's a polished document rather than a list of 4*headings,
  ;; then one wants the 4*headings at the top, where they're noticeable.

  (condition-case nil
      (progn
        (re-search-forward "^* ") ; set point before first 1*heading

        (if (eq (buffer-substring-no-properties (- (point) 2) (point)) "\n\n")
            (progn (backward-char) (insert ts-object-text))
          (insert ts-object-text)
          )
        )
    (error (ts-insert-to-end-of-buffer)))

  (save-buffer)

  ;; Sloppy imperative programming method of returning to the original perspective.
  (switch-to-buffer ts-buffer-target-1)
  (select-window ts-window-home)
  )
;; **** outline TODO
;; ***** main defun

(defun ts-throw-text-to-outline (x)
  "Appends current line to the body of a selected child heading.  Assumes parent heading is at the top of the visible region.

Prompts user for input.  Asks for enough letters from the beginning of the target child heading to distinguish it from the other immediate children of the parent heading.  Searches for a simple string.  Takes the first match.  Does not take any other arguments.

If no match found, fails with an error, and does not kill the line."

  (interactive "sEnter target heading's unique prefix: ")

  ;; fail with an error if user passes a bad heading prefix BEFORE deleting the line to be thrown.  To avoid data loss
  (save-excursion
    (ts-goto-target-heading))
  (other-window 1)

  ;; safe to proceed.  commence throwing the line.

  ;; cut the object line
  (beginning-of-line)
  (kill-line 1)

  (ts-goto-target-heading)

  ;; go to end of target heading, add a blank line, and yank.
  (org-narrow-to-subtree)
  (goto-char (point-max))
  (newline)
  (yank)
  (goto-char (point-max)) ; prevents edge case where yank into empty category causes failure to restore perspective

  ;; restore original perspective
  (goto-char (point-min))
  (widen)
  (outline-up-heading 1)
  (org-narrow-to-subtree)
  (other-window 1))

;; ***** goto target heading

;; *****  main defun

(defun ts-goto-target-heading ()
  "Finds a heading in the other window."

  (search-forward
   (concat (ts-print-starry-string)
           (message "%s" x) ; user-entered text
           )))

;; *****  print starry string

;; *****   main defun

(defun ts-print-starry-string ()
  "Print the n* prefix of the target heading
for the search string."

  ;; side effect: switches to other window, top heading
  (concat "\n" ; newline avoids grabbing subheading matches
   (make-string (+ (ts-top-heading-stars) 1) ?*) ; makes n *'s
   " "))

;; *****   target max heading level

(defun ts-top-heading-stars ()
  "Returns target window's top outline heading level.
Bounces point to target top visible heading & counts *'s."

  (other-window 1)
  (goto-char (point-min))
  (skip-chars-forward "*"))


;; *** throw up
;; **** main defun

(defun ts-throw-up()
  "Throw file or text one directory upwards"
  (interactive)

  (let ((ts-destination-dir (ts-jump-destination)))

    (if (eq major-mode 'dired-mode)
        (ts-throw-up-file)
      (ts-throw-up-text))
    )
  )
;; **** jump height

(defun ts-jump-destination ()
  "How high should ts-throw-up jump?"

  (let ((ts-home-path default-directory)
        )
    ;; jump either two directories or one
    (if (ts-parent-equal-inbox)
        (setq ts-jump "../../")
      (setq ts-jump "../"))
    (concat ts-home-path ts-jump)
    )
  )

;; **** object = text TODO

(defun ts-throw-up-text ()
  "Throw text to ../Inbox.org."

  (ts-snort-visible)
  (ts-open-target-buffer)
  (ts-throw-text-to-file)
  (set-buffer ts-buffer-home)
  )
;; **** target = file

(defun ts-throw-up-file ()
  "Throw file upwards in the dir tree to the next /0-Inbox"

  (mkdir ts-destination-dir t)
  (rename-file (dired-get-filename "no-dir") ts-destination-dir)
  (revert-buffer) ; refresh screen. necessary?
  )

;; *** batch TODO
;; **** batch throw TODO

(defun ts-batch-throw ()
  "Loop ts-throw infinitely. C-g to quit."
  (interactive)

  (condition-case nil
      (let ((count 0))
        (while (< count 100)
          (ts-throw)
          (setq count (1+ count))))
    (error "%s" "Done running batch throw"))
  (other-window 1)
  )
;; **** batch throw up TODO

(defun ts-batch-throw-up ()
  "Loop ts-throw-up infinitely. C-g to quit."
  (interactive)

  (condition-case nil
      (let ((count 0))
        (while (< count 100)
          (ts-throw-up)
          (setq count (1+ count))))
    (error "%s" "Done running batch throw"))
  (other-window 1)
  )
;; *** library DONE
;; **** snort a line DONE

(defun ts-snort-line ()
  ""
  ;; avoids error when snorting line from end of buffer
  (condition-case nil
      (setq ts-object-text
            (delete-and-extract-region (line-beginning-position)
                                       (+ 1 (line-end-position))))
    (error (setq ts-object-text
                 (delete-and-extract-region (line-beginning-position) (buffer-end 1))))
    )
  )
;; **** files DONE
;; ***** Find the searched dired entry DONE

(defun ts-searched-file-path ()
  "Finds the isearched dired entry"

    (goto-char (point-min))
    (forward-line)
    (isearch-forward)
    (dired-get-filename)
  )

;; ***** create an Inbox.org or switch to the buffer if it's open DONE

;; avoids warnings that underlying file has changed, and/or losing unsaved changes.
(defun ts-create-open-inbox-org (filename)
  ""
  (if (f-exists? filename)
      (switch-to-buffer (find-file-noselect filename))
    (progn (set-buffer (find-file-noselect filename)) ; TODO should just navigate to correct dired buffer
           (ts-create-inbox-org)))
  )
;; ***** check whether immediate parent dir is "0-Inbox" DONE

(defun ts-parent-equal-inbox ()
  "return t if parent dir is 0-Inbox"

  (equal
   (file-name-nondirectory (directory-file-name default-directory)) ; returns parent directory
   "0-Inbox")
  )
;; ***** Inbox.org creation DONE
;; ****** Create Inbox.org DONE

(defun ts-create-inbox-org ()
  "If Inbox.org doesn't already exist, creates it with *** offset."

  (setq ts-inbox-file-path
        (concat ts-searched-file-path "/Inbox\.org"))

  (setq ts-destination-buffer (find-buffer-visiting ts-inbox-file-path))

  (cond (ts-destination-buffer (set-buffer ts-destination-buffer)) ; select buffer
        ((file-exists-p ts-inbox-file-path) (find-file ts-inbox-file-path)) ; open file
        ;; or create and open file
        (t (progn (f-touch ts-inbox-file-path)
                  (write-region "*** offset\n" nil ts-inbox-file-path)
                  (find-file ts-inbox-file-path))
           )
        )
  )
;; ** minor utilities
;; *** C-c k QUICK KILL

(defun ts-delete-this-buffer-and-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)

  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))

    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (if (buffer-narrowed-p)
          (error "Buffer is narrowed!")
        (when (yes-or-no-p "Are you sure you want to remove this file? ")
          (delete-file filename)
          (kill-buffer buffer)
          (message "File '%s' successfully removed" filename)))))
  )
;; *** org links
;; **** create Zinks.org

(defun ts-dired-zinks
    ()
  "From Dired, creates a 'Zinks' file with anchor org-id link."
  (interactive)

  (find-file "Zinks.org")

  (insert (concat "*** " (file-name-directory buffer-file-name)))
  (save-buffer)
  (org-id-store-link)

  ;; superfluous if I configure org-mode to create these drawers closed
  (forward-line)
  (org-cycle)

  (goto-char (point-max)))

;; **** Store link and hide the PROPERTIES drawer

(defun ts-store-link-hide-drawer ()
  (interactive)

  (save-excursion
    (save-restriction
    (org-store-link nil t)
    (org-narrow-to-subtree)
    (outline-previous-visible-heading 1)
    (next-line)
    (org-show-all)
    (org-cycle)))
  )

;; *** proc sprinted
;; **** pipify word list

(defun ts-pipify-word-list
    ()
  "Converts multi-line word list into one line separated by pipes."
  (interactive)

  (end-of-line)
  (insert " | ")
  (delete-char 1)
  (end-of-line))

;; **** decompose a heading, after saving a mummy of it

(defun ts-decomposing-mummy ()
  "From a single-window frame in org-mode,
do setup to decompose a heading."
  (interactive)

  (mwim-beginning-of-code-or-line)
  (kill-new "")
  (kill-whole-line)
  (org-yank)
  (org-yank)
  (org-previous-visible-heading 2)
  (org-cycle)
  (mwim-end-of-line-or-code)
  (insert " | MUMMY")
  (org-cycle)
  (org-next-visible-heading 2)
  (org-ctrl-c-ret)

  (let ((position (point)))
    (clone-indirect-buffer-other-window "'Temporary" t)
    (goto-char position))
  (org-narrow-to-subtree)
  (other-window 1)
  (org-previous-visible-heading 1)
  (org-cycle)
  (org-narrow-to-subtree))
;; **** Textmind checklist funcs
;; ***** create new sprinting

(defun ts-create-new-sprinting ()
    "Make new sprinting heading in '1sprinting.org"
    (interactive)

  (set-buffer "'1sprinting.org")
  (widen)
  (goto-char (point-max))
  (insert "Creating new sprinting heading via elisp func.\n")
  (insert (concat "\n\n* Sprinting " (ts-org-time-and-date-stamp-inactive) "\n\n** proc sprinted\n\n*** deletion pass from bottom up\n\n"))
  (save-buffer))

;; ***** double-file prior sprinting log TODO

(defun ts-cut-prior-sprinting ()
  "File prior sprinting heading twice to '2sprinted.org"

  (set-buffer "'1sprinting.org")
  (widen)
  (goto-char (point-min))
  (org-next-visible-heading 1)
  (org-show-all '(headings))
  (org-cycle)
  (org-demote-subtree)
  (org-demote-subtree)
  (org-demote-subtree)
  (ts-snort-line)
  )

(defun ts-double-file-prior-sprinting ()
  "File prior sprinting heading twice to '2sprinted.org"

    (ts-cut-prior-sprinting)
    (find-file "~/1-Mansort/1-Textmind/2-Linked/8-Hud/'2sprinted.org")
    (goto-char (point-min))
    (word-search-forward "Log")
    (org-show-all '(headings))
    (org-cycle)
    (org-cycle)
    (org-forward-heading-same-level 1)
    (insert "\n")
    (backward-char)
    (org-yank)
    (newline)
    (save-buffer)

    (ts-create-open-inbox-org "../Inbox.org")
    (ts-create-inbox-org)
    (ts-insert-to-end-of-buffer)
    (save-buffer)
    (switch-to-buffer "'Meta.org")
  )
;; ***** deletion pass

(defun ts-proc-sprinted-deletion-pass ()
    "Setup other frame to begin deletion pass for proc sprinted checklist."

  (other-frame 1)
  (delete-other-windows)
  (find-file "~/1-Mansort/1-Textmind/2-Linked/Inbox.org")
  (org-show-all)
  (goto-char (point-max))
  )

;; ***** headingfy

(defun ts-headingfy ()
  "Create a heading and advance 2 paragraphs."
  (interactive)

  (org-open-line 2)
  (org-ctrl-c-ret)
  (insert "?")
  (org-forward-paragraph)
  (org-forward-paragraph)
  (recenter-top-bottom 10)
  (save-buffer)
  )

;; ***** lazy-title

(defun ts-lazy-title ()
  "Advance to next heading while lazy-titling proc sprinted."
  (interactive)

  (org-narrow-to-subtree)
  (org-previous-visible-heading 1)
  (widen)
  (org-cycle)
  (org-next-visible-heading 1)
  (org-narrow-to-subtree)
  (mwim-end-of-line-or-code)
  (save-buffer)
  )

;; ***** duplicate line to other window TODO

;; this is probably obsolete
(defun ts-duplicate-line-to-other-window ()
  "Copy line and yank to the bottom of the other window, then save."
  (interactive)

  (save-excursion
    (org-narrow-to-subtree)
    (copy-region-as-kill (goto-char (point-min)) (goto-char (point-max)))
    (widen)
    (other-window 1)
    (goto-char (point-max))
    (newline)
    (yank)
  (org-next-visible-heading 1)
  )
  )

;; ** library

;; *** text
;; **** snort visible region DONE

(defun ts-snort-visible ()
  ""
  (setq ts-object-text
        (concat
         (delete-and-extract-region (point-min) (point-max)) "\n"))
  (widen)

  (unless (eobp)
    (delete-char 1))
  )
;; **** insert at bottom of buffer DONE

(defun ts-insert-to-end-of-buffer ()
  "Adds object text to bottom of target file."

  (widen)
  (goto-char (point-max))
  (ts-empty-line-check)

  (insert ts-object-text)
  )
;; **** if line isn't empty, make newline

(defun ts-empty-line-check ()
  (unless (and (bolp) (eolp))
    (insert "\n"))
  )
;; *** open destination buffer from filename

(defun ts-open-destination-buffer-from-filename (filename)
  "Open target buffer, if it exists."

  (let ((ts-destination-buffer) (find-buffer-visiting filename))

    (if ts-destination-buffer
        ()
      (find-file filename))
    )
  )
;; ** provide

(provide 'treesort)
