
# Table of Contents

1.  [Undo-tree](#orgb278a12)
    1.  [Why a another version?](#org03cbca7)
    2.  [Why not submit a patch to Toby S. Cubitt?](#orge3c4871)
    3.  [What is the target of this fork?](#org63920a0)
    4.  [What might change (break compatibility with the original `undo-tree`)?](#org037e03e)
    5.  [What will not be fixed?](#org03d3a53)
2.  [Progress and Plan](#orgdab21dd)
    1.  [Clean up to make the byte compiler happy](#org3e01a3c)
    2.  [Migrate from legacy `cl` to `cl-lib`](#org7610c51)
    3.  [Clean up namespace](#orgb8d0737)
    4.  [Scan for infinite loops and possible source of hanging](#orgd3b7d8d)
        1.  [Fix incorrect loop in ~undo-list-clean-GCd-elts](#orgde031fd)
    5.  [Fix tree-size calculation](#orge9e0696)
    6.  [Fix save/load history](#orgb12817f)
    7.  [Fix history discard](#org7691a3b)
    8.  [Performance improvements](#orgdd08cad)
    9.  [Update tree visualizer](#orgcb8ac8a)
    10. [Debugging and testing facilities](#org6a3ba68)
    11. [Add a fully functioning logging system to help reproduce bugs](#org9740526)
    12. [`undo-tree-visualizer-mode` uses `buffer-undo-tree` directly](#orga94d9e2)
3.  [Known/unfixed bugs](#orgf92b5a0)
    1.  ["No further undo information"](#org19fcdf5)
    2.  ["Error reading undo-tree history from &#x2026;"](#orga00b714)
    3.  [Mismatch of real size of a tree and the maintained size](#orgabbb88a)
    4.  [Conflict with `multiple-cursors` and `iedit`](#orga98a157)
    5.  [`undo-in-region`](#org54a7538)


<a id="orgb278a12"></a>

# Undo-tree

Treat undo history as a tree. This package by Toby S. Cubitt has enjoyed great popularity among the world of emacsers. 


<a id="org03cbca7"></a>

## Why a another version?

Though Toby S. Cubitt claims never having issue with the "No further undo information" error in `undo-tree`, this infamous error haunts almost every emacer I know of. Furthermore, the development and maintenance has slowed down since 2014, or release 0.6.5. According to git history and Toby's homepage, only four commits were made after that, among which only one commit by Barry O'Reilly actually improves the code (there is another commit that adds warnings to interactive functions called outside undo-tree-mode, but it is not included in the latest release 0.6.6).


<a id="orge3c4871"></a>

## Why not submit a patch to Toby S. Cubitt?

I first thought of submitting small bug-fix patches. Then I realized the complexity and the amount of update I would like to see. It would be much easier if I can fork and refactor as wish, and fix the bugs as I come across. I will submit patches to Toby S. Cubitt when the code is in a stable shape with facilities to help me and other users to reproduce bugs.


<a id="org63920a0"></a>

## What is the target of this fork?

1.  Stay close to the original undo-tree
2.  Mainly bug fixes
3.  Add tests to make it robust enough


<a id="org037e03e"></a>

## What might change (break compatibility with the original `undo-tree`)?

1.  The format of the saved undo history. The current history save is just a hash of the file when the undo history was saved, concatenating with a flatted `buffer-undo-tree` (printed with `prin1`). This


<a id="org03d3a53"></a>

## What will not be fixed?

Since I do not use the `undo-in-region` feature, and this has been known as a source of instability for undo-tree. I am not going to look into it, at least not in the near future.


<a id="orgdab21dd"></a>

# Progress and Plan


<a id="org3e01a3c"></a>

## DONE Clean up to make the byte compiler happy


<a id="org7610c51"></a>

## DONE Migrate from legacy `cl` to `cl-lib`


<a id="orgb8d0737"></a>

## DONE Clean up namespace


<a id="orgd3b7d8d"></a>

## DONE Scan for infinite loops and possible source of hanging


<a id="orgde031fd"></a>

### DONE Fix incorrect loop in ~undo-list-clean-GCd-elts


<a id="orge9e0696"></a>

## TODO Fix tree-size calculation

The tree-size maintaining part seems buggy. The size of an undo-tree is not always the same as the value maintained in the data-structure.

-   [X] Fixed cons size: on 32-bit emacs, the size of a cons is 8, but on 64-bit emacs, it is 16.
-   [X] The size of undo-list is not calculated the same as in C source.
-   [X] Fix size calculation when a marker is garbage collected.
-   [ ] Mysterious mismatch of real size and maintained size. Need logging facility to recover the reason.


<a id="orgb12817f"></a>

## TODO Fix save/load history

-   [X] Add function to clean out markers that have been garbage collected, call it before saving and after restoring history.
-   [X] Decide on a new format of saving undo-tree. The current way of saving is almost impossible to debug when errors occur. Try to avoid references in the saved data structure.
-   [X] Implement the new form
-   [X] Add test for both old and new save/load
-   [ ] Add an option to save a copy of the current file in the undo-tree history, so that modifications from other editors will not ruin the whole history.
-   [ ] Understand markers and what is their behavior after being loaded.


<a id="org7691a3b"></a>

## TODO Fix history discard

-   [X] Clean up garbage collected markers before actually discarding history.
-   [ ] Find a better way of deciding which node to discard.


<a id="orgdd08cad"></a>

## TODO Performance improvements

-   [X] Write new version to find the common ancestor of two nodes. Current version goes all the way to the root.
-   [ ] Avoid frequent undoing to get diff.


<a id="orgcb8ac8a"></a>

## TODO Update tree visualizer

-   [X] Add milliseconds to timestamp strings.
-   [ ] Find a way of switch between showing diff to parrent node and showing diff to child.


<a id="org6a3ba68"></a>

## TODO Debugging and testing facilities

-   [X] Add function to calculate the size of the undo-tree.
-   [X] Add function to print out the whole undo-tree in a clearer way.


<a id="org9740526"></a>

## TODO Add a fully functioning logging system to help reproduce bugs


<a id="orga94d9e2"></a>

## TODO `undo-tree-visualizer-mode` uses `buffer-undo-tree` directly

Intuitively, `buffer-undo-tree` should be like `buffer-undo-list`, and is only related to a buffer. However, in `undo-tree-visualizer-mode`, `buffer-undo-tree` is pointed to the buffer it corresponds to. This can be a source of bugs.


<a id="orgf92b5a0"></a>

# Known/unfixed bugs


<a id="org19fcdf5"></a>

## "No further undo information"

Need a logging system to help reproduce and recover. Not happening recently to me though. Possible reasons:

-   **Text properties:** text properties are not really necessary for undo-tree, and can use up a lot of space. This can avoid truncating the undo history and corrupting the tree. Code borrowed from doom emacs.
-   **History truncating:** small limit of gc threshold may make things worse. [ref](https://github.com/syl20bnr/spacemacs/issues/12110)


<a id="orga00b714"></a>

## "Error reading undo-tree history from &#x2026;"

Need a new format of saving instead of the "hash + serialization of undo-tree" format. Happens often to me, this will be the priority.

Possible reason(s):

-   **Markers:** when printed using `prin1`, and loaded using `read`, things can go wrong.
-   **External edits:** when the file has been externally edited, no undo-history is possible. One way to solve it is to add a copy of the file while saving.


<a id="orgabbb88a"></a>

## Mismatch of real size of a tree and the maintained size

Happens occasionally for me, but also needs a logging system to monitor the offending action.


<a id="orga98a157"></a>

## Conflict with `multiple-cursors` and `iedit`

Observed this once or twice. Will fix after proper reproduction facility is ready.


<a id="org54a7538"></a>

## `undo-in-region`

Won't fix.

