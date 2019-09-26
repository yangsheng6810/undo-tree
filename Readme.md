
# Table of Contents

1.  [Undo-tree](#orgbbd6a8a)
    1.  [Why a another version?](#org234b4e1)
    2.  [Why not submit a patch to Toby S. Cubitt?](#org7a7df25)
    3.  [What is the target of this fork?](#org9a9dece)
    4.  [What might change (break compatibility with the original `undo-tree`)?](#org61aac1a)
    5.  [What will not be fixed?](#orge0f5658)
2.  [Progress and Plan](#org73e3cc3)
    1.  [Clean up to make the byte compiler happy](#orgbe9ff4b)
    2.  [Migrate from legacy `cl` to `cl-lib`](#org873461f)
    3.  [Clean up namespace](#org4e6e416)
    4.  [Scan for infinite loops and possible source of hanging](#org11fe604)
        1.  [Fix incorrect loop in ~undo-list-clean-GCd-elts](#orgd76d17d)
    5.  [Fix tree-size calculation](#orga85c3db)
    6.  [Fix save/load history](#orgea69871)
    7.  [Fix history discard](#org98c5f57)
    8.  [Performance improvements](#orgacbcebc)
    9.  [Update tree visualizer](#orgd02ff52)
    10. [Debugging and testing facilities](#orgdcff1e6)
    11. [Add a fully functioning logging system to help reproduce bugs](#org7a88852)
    12. [`undo-tree-visualizer-mode` uses `buffer-undo-tree` directly](#orge61b9c8)
3.  [Known/unfixed bugs](#org55a284c)
    1.  ["No further undo information"](#org106e40d)
    2.  ["Error reading undo-tree history from &#x2026;"](#org25f375e)
    3.  [Mismatch of real size of a tree and the maintained size](#org897616c)
    4.  [Conflict with `multiple-cursors` and `iedit`](#orgf56f09b)
    5.  [`undo-in-region`](#org9255304)


<a id="orgbbd6a8a"></a>

# Undo-tree

Treat undo history as a tree. This package by Toby S. Cubitt has enjoyed great popularity among the world of emacsers. 


<a id="org234b4e1"></a>

## Why a another version?

Though Toby S. Cubitt claims never having issue with the "No further undo information" error in `undo-tree`, this infamous error haunts almost every emacer I know of. Furthermore, the development and maintenance has slowed down since 2014, or release 0.6.5. According to git history and Toby's homepage, only four commits were made after that, among which only one commit by Barry O'Reilly actually improves the code (there is another commit that adds warnings to interactive functions called outside undo-tree-mode, but it is not included in the latest release 0.6.6).


<a id="org7a7df25"></a>

## Why not submit a patch to Toby S. Cubitt?

I first thought of submitting small bug-fix patches. Then I realized the complexity and the amount of update I would like to see. It would be much easier if I can fork and refactor as wish, and fix the bugs as I come across. I will submit patches to Toby S. Cubitt when the code is in a stable shape with facilities to help me and other users to reproduce bugs.


<a id="org9a9dece"></a>

## What is the target of this fork?

1.  Stay close to the original undo-tree
2.  Mainly bug fixes
3.  Add tests to make it robust enough


<a id="org61aac1a"></a>

## What might change (break compatibility with the original `undo-tree`)?

1.  The format of the saved undo history. The current history save is just a hash of the file when the undo history was saved, concatenating with a flatted `buffer-undo-tree` (printed with `prin1`). This


<a id="orge0f5658"></a>

## What will not be fixed?

Since I do not use the `undo-in-region` feature, and this has been known as a source of instability for undo-tree. I am not going to look into it, at least not in the near future.


<a id="org73e3cc3"></a>

# Progress and Plan


<a id="orgbe9ff4b"></a>

## DONE Clean up to make the byte compiler happy


<a id="org873461f"></a>

## DONE Migrate from legacy `cl` to `cl-lib`


<a id="org4e6e416"></a>

## DONE Clean up namespace


<a id="org11fe604"></a>

## DONE Scan for infinite loops and possible source of hanging


<a id="orgd76d17d"></a>

### DONE Fix incorrect loop in ~undo-list-clean-GCd-elts


<a id="orga85c3db"></a>

## TODO Fix tree-size calculation

The tree-size maintaining part seems buggy. The size of an undo-tree is not always the same as the value maintained in the data-structure.

-   [X] Fixed cons size: on 32-bit emacs, the size of a cons is 8, but on 64-bit emacs, it is 16.
-   [X] The size of undo-list is not calculated the same as in C source.
-   [X] Fix size calculation when a marker is garbage collected.
-   [ ] Mysterious mismatch of real size and maintained size. Need logging facility to recover the reason.


<a id="orgea69871"></a>

## TODO Fix save/load history

-   [X] Add function to clean out markers that have been garbage collected, call it before saving and after restoring history.
-   [ ] Decide on a new format of saving undo-tree. The current way of saving is almost impossible to debug when errors occur. Try to avoid references in the saved data structure.
-   [ ] Implement the new form
-   [ ] Add an option to save a copy of the current file in the undo-tree history, so that modifications from other editors will not ruin the whole history.
-   [ ] Understand markers and what is their behavior after being loaded.


<a id="org98c5f57"></a>

## TODO Fix history discard

-   [X] Clean up garbage collected markers before actually discarding history.
-   [ ] Find a better way of deciding which node to discard.


<a id="orgacbcebc"></a>

## TODO Performance improvements

-   [X] Write new version to find the common ancestor of two nodes. Current version goes all the way to the root.
-   [ ] Avoid frequent undoing to get diff.


<a id="orgd02ff52"></a>

## TODO Update tree visualizer

-   [X] Add milliseconds to timestamp strings.
-   [ ] Find a way of switch between showing diff to parrent node and showing diff to child.


<a id="orgdcff1e6"></a>

## TODO Debugging and testing facilities

-   [X] Add function to calculate the size of the undo-tree.
-   [X] Add function to print out the whole undo-tree in a clearer way.


<a id="org7a88852"></a>

## TODO Add a fully functioning logging system to help reproduce bugs


<a id="orge61b9c8"></a>

## TODO `undo-tree-visualizer-mode` uses `buffer-undo-tree` directly

Intuitively, `buffer-undo-tree` should be like `buffer-undo-list`, and is only related to a buffer. However, in `undo-tree-visualizer-mode`, `buffer-undo-tree` is pointed to the buffer it corresponds to. This can be a source of bugs.


<a id="org55a284c"></a>

# Known/unfixed bugs


<a id="org106e40d"></a>

## "No further undo information"

Need a logging system to help reproduce and recover. Not happening recently to me though.


<a id="org25f375e"></a>

## "Error reading undo-tree history from &#x2026;"

Need a new format of saving instead of the "hash + serialization of undo-tree" format. Happens often to me, this will be the priority.


<a id="org897616c"></a>

## Mismatch of real size of a tree and the maintained size

Happens occasionally for me, but also needs a logging system to monitor the offending action.


<a id="orgf56f09b"></a>

## Conflict with `multiple-cursors` and `iedit`

Observed this once or twice. Will fix after proper reproduction facility is ready.


<a id="org9255304"></a>

## `undo-in-region`

Won't fix.

