-- Tools for generating files based on templates.

module Template (Piece(..), Template(..), fill) where

import Control.Monad
import Data.List (sort)
import System.Directory (listDirectory)
import System.FilePath.Posix ((</>))

-- A template is a list of pieces. All paths are relative to the parent
-- directory of the file to be generated.
data Piece =
    -- A string to be copied exactly.
    Verbatim String
    -- Copy the contents of the file unchanged.
  | ReadFile FilePath
    -- List the files from a directory with Markdown links. The files are
    -- listed in reverse lexicographic order.
  | MarkdownFileList FilePath

newtype Template = Template [Piece]

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
             ]
  in liftM concat $ sequence (map fillPiece pieces)
