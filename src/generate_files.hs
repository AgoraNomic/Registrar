-- Usage: from the same directory as this file,
--   runghc generate_files.hs

import Control.Monad
import System.FilePath.Posix ((</>))
import System.Process (readCreateProcess, shell)
import qualified Template

data FileToGenerate =
  F
  { templatePath :: FilePath
  , outputParentDirectory :: FilePath
  , outputName :: FilePath
  }

filesToGenerate :: [FileToGenerate]
filesToGenerate =
  [ F "../templates/index" ".." "index.md"
  ]

-- Returns Right () if the git repository containing the current directory is
-- clean. Otherwise returns some information about how it's not clean
-- (currently the output of git status --porcelain).
gitRepoIsClean :: IO (Either String ())
gitRepoIsClean =
  do gitOutput <- readCreateProcess (shell "git status --porcelain") ""
     return $
       if gitOutput == ""
       then Right ()
       else Left gitOutput

leftToError :: String -> IO (Either String a) -> IO a
leftToError messagePrefix x =
  do result <- x
     case result of
       Left e -> error (messagePrefix ++ e)
       Right y -> return y

generateFile :: FileToGenerate -> IO ()
generateFile f =
  do template <- leftToError ("Error parsing template at " ++ templatePath f ++ ":\n") (liftM Template.parse (readFile (templatePath f)))
     generatedContent <- Template.fill template (outputParentDirectory f)
     writeFile (outputParentDirectory f </> outputName f) generatedContent

main :: IO ()
main =
  do ---- TODO: Figure out a sensible thing to replace this check. The repository
     ---- will typically not be clean because the user will have edited a template
     ---- or one of its inputs and will want to try out the template.
     -- leftToError "git repo not clean:\n" gitRepoIsClean
     sequence_ (map generateFile filesToGenerate)
