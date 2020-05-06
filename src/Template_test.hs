import Template
import Test.Tasty
import qualified Test.Tasty.HUnit as HU
import Test.Tasty.HUnit ((@?=))

unusedPath :: FilePath
unusedPath = "."

main :: IO ()
main =
  defaultMain $ testGroup "Template"
  [ HU.testCase "Empty template gives nothing." $
    do result <- fill (Template []) unusedPath
       result @?= ""
  , HU.testCase "Copies verbatim string." $
    do result <- fill (Template [Verbatim "string"]) unusedPath
       result @?= "string"
  , HU.testCase "Reads file contents." $
    do result <- fill (Template [ReadFile "test_data/hello"]) "."
       result @?= "Hello, world!\n"
  , HU.testCase "Uses relative path when reading file contents." $
    do result <- fill (Template [ReadFile "hello"]) "test_data"
       result @?= "Hello, world!\n"
  , HU.testCase "Accounts for .. in relative paths." $
    do result <- fill (Template [ReadFile "hello"]) "test_data/../test_data"
       result @?= "Hello, world!\n"
  , HU.testCase "Concatenates file contents." $
    do result <- fill (Template [ReadFile "test_data/hello", ReadFile "test_data/apple"]) unusedPath
       result @?= "Hello, world!\napple\n"
  , HU.testCase "Lists directory in reverse lexicographic order." $
    do result <- fill (Template [MarkdownFileList "test_data/directory"]) "."
       result @?= "* [A.txt](test_data/directory/A.txt)\n* [01](test_data/directory/01)\n* [00](test_data/directory/00)\n"
  , HU.testCase "Lists directory using relative paths." $
    do result <- fill (Template [MarkdownFileList "directory"]) "test_data"
       result @?= "* [A.txt](directory/A.txt)\n* [01](directory/01)\n* [00](directory/00)\n"
  , HU.testCase "Concatenates different kinds of piece." $
    do result <- fill (Template [Verbatim "X\n", MarkdownFileList "test_data/directory", ReadFile "test_data/hello"]) "."
       result @?= "X\n* [A.txt](test_data/directory/A.txt)\n* [01](test_data/directory/01)\n* [00](test_data/directory/00)\nHello, world!\n"
  ]
