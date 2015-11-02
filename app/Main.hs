module Main where

import Lib

import Control.Monad (mzero)
import Control.Monad.IO.Class (liftIO)
import Data.Aeson
import Data.Aeson.Types
import Data.Maybe
import Data.Monoid
import Data.String.Conversions (cs)
import Data.Text
import Database.PostgreSQL.Simple
import Network.HTTP.Types (status400, status403)
import Web.Scotty
import qualified Data.ByteString.Lazy as BL

main = do
  conn <- connectPostgreSQL "postgresql://j:@localhost:5432/temp"
  scotty 3000 $ do
    post "/tokens" $ do
      payload <- body
      case eitherDecode payload of
        Right (LoginAttempt user pass) -> do
          mRole <- liftIO $ loginRole conn user pass
          case mRole of
            Just role -> text $ cs role
            Nothing ->
              status status403
        Left e -> do
          status status400
          text (cs e)

data LoginAttempt = LoginAttempt {
    laUser :: Text
  , laPass :: Text
  }
instance FromJSON LoginAttempt where
  parseJSON (Object o) =
    LoginAttempt <$> o .: "user" <*> o .: "pass"
  parseJSON _ = mzero
