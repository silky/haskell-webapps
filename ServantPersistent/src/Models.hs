{-# LANGUAGE DataKinds       #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeOperators   #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilyDependencies #-}
{-# LANGUAGE TypeInType #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Models
    where

import Data.Aeson
import Data.Aeson.TH
import Database.Persist.Sql
import Database.Persist.TH
import GHC.Generics
import Data.Time.Clock
import Data.Text
import Control.Monad.IO.Class
import Control.Monad.Reader
import Control.Lens
import Data.ByteString
import Data.Proxy
import Types

share [mkPersist sqlSettings { mpsGenerateLenses = True }, mkMigrate "migrateAll"] [persistLowerCase|
DBTenant json
    name Text
    backofficeDomain Text
    ownerId DBUserId Maybe
    status TenantStatus
    createdAt UTCTime
    updatedAt UTCTime
    UniqueTenant name backofficeDomain

DBUser
    firstName Text
    lastName Text
    tenantID DBTenantId
    username Text
    password ByteString
    status UserStatus
    createdAt UTCTime
    updatedAt UTCTime
    UniqueUsername username
|]

type TenantID = Key DBTenant
type Tenant = DBTenant
type TenantOutput = DBTenant

instance HasTimestamp DBTenant where
    createdAt = dBTenantCreatedAt
    updatedAt = dBTenantUpdatedAt
instance HasTimestamp DBUser where
    createdAt = dBUserCreatedAt
    updatedAt = dBUserUpdatedAt

instance HasTenantIdent DBTenant where
    name = dBTenantName
    backofficeDomain = dBTenantBackofficeDomain
    tenantIdent =
        lens (TI <$> (^. name) <*> (^. backofficeDomain)) (\s b ->
          s & (name .~) (b^.name)
            & (backofficeDomain .~) (b^. backofficeDomain))

runDb :: (MonadReader Config m, MonadIO m) => SqlPersistT IO b -> m b
runDb query = do
    pool <- asks dbPool
    liftIO $ runSqlPool query pool
