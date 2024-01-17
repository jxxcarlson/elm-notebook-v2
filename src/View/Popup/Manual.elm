module View.Popup.Manual exposing (view)

import Element
import Element.Background as Background
import Element.Font as Font
import Types exposing (PopupState(..))
import View.Button
import View.Geometry
import View.MarkdownThemed as MarkdownThemed
import View.Utility


view model theme =
    View.Utility.showIf (model.popupState == ManualPopup) <|
        Element.column
            [ Background.color theme.background
            , Element.width (Element.px <| View.Geometry.appWidth model // 2)
            , Element.height (Element.px <| View.Geometry.bodyHeight model)
            , Element.moveUp (toFloat <| View.Geometry.bodyHeight model)
            , Element.padding 48
            , Element.alignRight
            , Element.clipX
            ]
            [ Element.el [ Element.alignRight ] View.Button.dismissPopupTransparent
            , MarkdownThemed.renderFull (scale 0.42 (View.Geometry.appWidth model)) (View.Geometry.bodyHeight model) content
            ]


scale : Float -> Int -> Int
scale factor x =
    round <| factor * toFloat x


image source description caption =
    Element.newTabLink [] { url = source, label = image_ source description caption }


image_ source description caption =
    Element.column [ Element.spacing 8, Element.width (Element.px 400), Element.paddingEach { top = 12, bottom = 48, left = 0, right = 0 } ]
        [ Element.image [ Element.centerX, Element.width (Element.px 350) ] { src = source, description = description }
        , Element.el [ Element.centerX, Font.size 13 ] (Element.text caption)
        ]



-- image "https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/30f08d58-dbce-42a0-97a6-512735707700/public" "bird" "Mascot"
--<img src="https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/30f08d58-dbce-42a0-97a6-512735707700/public"
--description="bird"
--caption="Mascot">
--</img>


content =
    """


## This Manual


Click on the **Manual** button to show or hide the manual.

## Cells

**Kinds of Cells**

There are two kinds of cells: markdown cells and code cells.
Markdown cells are used to write text. Code cells are used to write Elm code:

  - expression to be evaluated, like `2 + 2` or `List.length [1,2,3]`. 
  - declarations, like `a = 2` or `b = [1,2,3]`
  - type definitions, like `type alias Point = { x : Float, y : Float }`
  - import statements, like `import List.Extra`, `import List.Extra as LE`, or `import List.Extra exposing (..)`



**Working with Cells**

Click on a cell to edit it or to evaluate the code in it.
To evaluate a cell, type `Ctrl-Enter`, or click on the *Run* button
in the cell controls (see below).

When you click on a cell, the app will display a row of controls:

 - *Above/Below*, *New Code*, *New Text*.  Use these to create new cells.
 The *Above/Below* toggles the placement of the newly created cell.

 - *Close* (for Markdown cells) or *Run* (for code cells).
 The *Run* button evaluates the code in the cell, the
result of which is shown below the code itself.

- *Up*, *Down*: move cells up or down.

 - *Delete*, *Clear*, *Locked* or *Unlocked*. Clicking the *Clear* button
 removes the result of evaluating the cell or error messages if any.  Clicking the
 *Locked/Unlocked* button locks or unlocks the cell.  Locked cells cannot be edited.


## Packages

The *Packages* button opens a window that lets you add packages to your notebook.
This window has two parts   In the upper part you list the names of the
packages your notebook needs, e.g. `elm-community/list-extra`.
The app remembers what you put there, so if you open it again, you can add, edit, or delete
package names. The lower part lists the packages that are currently installed in
the Elm compiler.

## Public versus private notebooks

Notebooks are either public or private.  Public notebooks are visible to all users.
To change the status of a notebook, click on the *Private* button in the notebook footer.

You can work with a pubic notebook that does not belong to you: edit and evaluate
cells, delete cells and make new ones. However, these changes will not be saved.
If you want to save changes to a public notebook, clone it (see below)  Cloning a notebook
creates a copy of the notebook that belongs to you.  To clone a notebook you need
an Elm Notebook account, and you need to be signed in to it.

Note the two buttons *My docs* and *Public docs* at the top of the notebook list (right-hand column).
Click on the *My docs*
button to show your documents. Click on *Public docs* to show public documents that do not
belong to you.

## Opening a public document without signing in

You can open a public document if you know its "address" on the internet.
For example, there is a public document called **Collatz Conjecture.**
You you can open by pointing your browser at

- [elm-notebook.org/open/jxxcarlson-collatz-conjecture](https://elm-notebook.org/open/jxxcarlson-collatz-conjecture).

Abbreviated versions of the address also work:

 - [elm-notebook.org/open/jxxcarlson-collatz](https://elm-notebook.org/open/jxxcarlson-collatz)

 - [elm-notebook.org/open/collatz](https://elm-notebook.org/open/collatz)

 Documents that you open this way are opened in guest mode.  You can edit them, run code, etc. However,
 your changes will not be saved. This feature can be useful for classes.  Just put these links on your
 class website for your student's convenience.

## Cloning a notebook

Public documents can be cloned by clicking on the *Clone* button in the footer.  This button
is only visible if the *Public docs*, not the *My docs* button is selected, and if there are
public notebooks visible.

You can also update a notebook that has been cloned: click on the *Update* button in the footer.
Updating a notebook brings in new material from the original source.
However this operation will overwrite any changes you have made to the clone.

As with any notebook, you can rename one that has been cloned. To do this, click on the title field
in the header, left-hand side.


"""


old =
    """
## Working with data

Data can
be imported from a `.csv` file and stored in a variable using the command `readinto`.
The command `readinto foo` will store the file contents in the variable `foo`.
To visualize imported data, use the `chart` command, e.g.,
`chart timeseries columns:1 foo` to display a time series of the data in column 1
of `foo`, or `chart scatter columns:3,5 foo` for a scatter plot of the
data in columns 3 and 5..  See the public notebook
**Data, Charts, and Images** for examples.


## The Dataset Library

Elm notebooks has a library of sample data sets. One of these
is `jxxcarlson.stocks`.
To import it,  say `import jxxcarlson.stocks`.  The contents of
this dataset will be stored in the variable `jxxcarlson.stocks`
of the current notebook.  To store it in the variable `foo`, say
`import jxxcarlson.stocks as foo` instead. Again, see
the public notebook **Data, Charts, and Images** for examples.

To create a data set from a file on your computer, click
on the button 'New Data Set' in the footer.
In the reverse direction, you can export a data set to a file  with the
 command `export jxxcarlson.stocks`.
"""
