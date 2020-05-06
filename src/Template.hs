-- Tools for generating files based on templates.

module Template (Piece(..), Template(..), fill, parse) where

import Control.Monad
import Data.List (sort)
import Data.Maybe (listToMaybe)
import System.Directory (listDirectory)
import System.FilePath.Posix ((</>))

-- A template is a list of pieces. All paths are relative to the parent
-- directory of the file to be generated.
data Piece =
    -- A string to be copied exactly.
    Verbatim String
    -- Copy the contents of the file unchanged.
  | ReadFile FilePath
    -- List the files from a directory with Markdown links, excluding
    -- "fresh.txt". The files are listed in reverse lexicographic order.
  | MarkdownFileList FilePath
  deriving (Eq, Read, Show)

newtype Template = Template [Piece] deriving (Eq, Show)

-- Given a template and the parent directory where a generated file should
-- live, fill in the template.
fill :: Template -> FilePath -> IO String
fill (Template pieces) outputParent =
  let fillPiece :: Piece -> IO String
      fillPiece (Verbatim x) = return x
      fillPiece (ReadFile path) = readFile (outputParent </> path)
      fillPiece (MarkdownFileList path) =
        do fileNames <- listDirectory (outputParent </> path)
           return $
             unlines
             [ "* [" ++ fileName ++ "](" ++ (path </> fileName) ++ ")"
             | fileName <- reverse (sort fileNames)
             , fileName /= "fresh.txt"
             ]
  in liftM concat $ sequence (map fillPiece pieces)

-- Parse a template. Returns Left (error message) if there's a problem.
parse :: String -> Either String Template
parse =
  let isNotBrace x = not (x == '{' || x == '}')
      parseFrom acc "" = Right (Template (reverse acc))
      parseFrom acc x@(_:_) =
        case span isNotBrace x of
          (v, "") -> Right (Template (reverse (Verbatim v : acc)))
          (v, '{' : t) ->
            case span (/= '}') t of
              (_, "") -> Left "Unmatched '{'."
              (k, '}' : t') ->
                case readM k of
                  Nothing -> Left ("Could not parse " ++ show k ++ ".")
                  Just piece ->
                    let acc' = if v == "" then acc else Verbatim v : acc in
                      parseFrom (piece : acc') t'
          (_, '}' : _) -> Left "Unmatched '}'."
  in parseFrom []

readM :: Read a => String -> Maybe a
readM x = listToMaybe [y | (y, "") <- reads x]
