module Lib where

import Data.Text
import Database.PostgreSQL.Simple
import Database.PostgreSQL.Simple.SqlQQ

loginRole :: Connection -> Text -> Text -> IO (Maybe Text)
loginRole c user pass = do
  res <- query c "select login_role(?,?)" (user, pass)
  return $ case res of
    [Only (Just role)] -> Just role
    _ -> Nothing
