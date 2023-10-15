module Notebook.Codec exposing (encodePackageList, exportBook, importBook)

import Codec exposing (Codec, Error, Value)
import Notebook.Book exposing (Book)
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.Types exposing (MessageItem(..), Package, ReplData, StyledString)
import Time


exportBook : Book -> String
exportBook book =
    Codec.encodeToString 4 bookCodec book


importBook : String -> Result Error Book
importBook str =
    Codec.decodeString bookCodec str


encodePackageList : List Package -> Value
encodePackageList packageList =
    Codec.encodeToValue packageListCodec packageList


packageListCodec : Codec (List Package)
packageListCodec =
    Codec.list packageCodec


packageCodec : Codec Package
packageCodec =
    Codec.object Package
        |> Codec.field "name" .name Codec.string
        |> Codec.field "version" .version Codec.string
        |> Codec.buildObject


bookCodec : Codec Book
bookCodec =
    Codec.object Book
        |> Codec.field "id" .id Codec.string
        |> Codec.field "dirty" .dirty Codec.bool
        |> Codec.field "slug" .slug Codec.string
        |> Codec.field "origin" .origin (Codec.maybe Codec.string)
        |> Codec.field "author" .author Codec.string
        |> Codec.field "createdAt" .createdAt timeCodec
        |> Codec.field "updatedAt" .updatedAt timeCodec
        |> Codec.field "public" .public Codec.bool
        |> Codec.field "title" .title Codec.string
        |> Codec.field "cells" .cells (Codec.list cellCodec)
        |> Codec.field "currentIndex" .currentIndex Codec.int
        |> Codec.field "packageNames" .packageNames (Codec.list Codec.string)
        |> Codec.field "tags" .tags (Codec.list Codec.string)
        |> Codec.field "options" .options (Codec.dict Codec.string)
        |> Codec.buildObject


timeCodec : Codec Time.Posix
timeCodec =
    Codec.map Time.millisToPosix Time.posixToMillis Codec.int


cellCodec : Codec Cell
cellCodec =
    Codec.object Cell
        |> Codec.field "index" .index Codec.int
        |> Codec.field "text" .text Codec.string
        |> Codec.field "tipe" .tipe cellTypeCodec
        |> Codec.field "value" .value cellValueCodec
        |> Codec.field "cellState" .cellState cellStateCodec
        |> Codec.field "locked" .locked Codec.bool
        |> Codec.field "report" .report (Codec.maybe <| Codec.list messageItemCodec)
        |> Codec.field "replData" .replData (Codec.maybe <| replDataCodec)
        |> Codec.buildObject


replDataCodec : Codec ReplData
replDataCodec =
    Codec.object ReplData
        |> Codec.field "name" .name (Codec.maybe Codec.string)
        |> Codec.field "value" .value Codec.string
        |> Codec.field "tipe" .tipe Codec.string
        |> Codec.buildObject


messageItemCodec : Codec MessageItem
messageItemCodec =
    Codec.custom
        (\plain styled value ->
            case value of
                Plain s ->
                    plain s

                Styled ss ->
                    styled ss
        )
        |> Codec.variant1 "Plain" Plain Codec.string
        |> Codec.variant1 "Styled" Styled styledStringCodec
        |> Codec.buildCustom


styledStringCodec : Codec StyledString
styledStringCodec =
    Codec.object StyledString
        |> Codec.field "bold" .bold Codec.bool
        |> Codec.field "underline" .underline Codec.bool
        |> Codec.field "color" .color (Codec.maybe Codec.string)
        |> Codec.field "string" .string Codec.string
        |> Codec.buildObject


cellTypeCodec : Codec CellType
cellTypeCodec =
    Codec.custom
        (\ctcode ctmarkdown value ->
            case value of
                CTCode ->
                    ctcode

                CTMarkdown ->
                    ctmarkdown
        )
        |> Codec.variant0 "CTCode" CTCode
        |> Codec.variant0 "CTMarkdown" CTMarkdown
        |> Codec.buildCustom


cellValueCodec : Codec CellValue
cellValueCodec =
    Codec.custom
        (\fcvnone cvstring cmarkdown value ->
            case value of
                CVNone ->
                    fcvnone

                CVString s ->
                    cvstring s

                CVMarkdown s ->
                    cmarkdown s
        )
        |> Codec.variant0 "CVNone" CVNone
        |> Codec.variant1 "CV" CVString Codec.string
        |> Codec.variant1 "CVMarkdown" CVMarkdown Codec.string
        |> Codec.buildCustom



--


cellStateCodec : Codec CellState
cellStateCodec =
    Codec.custom
        (\fcsedit fcsview value ->
            case value of
                CSEdit ->
                    fcsedit

                CSView ->
                    fcsview
        )
        |> Codec.variant0 "CSEdit" CSEdit
        |> Codec.variant0 "CSView" CSView
        |> Codec.buildCustom
