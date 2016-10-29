module DataTypes
  (Tenant(..)
  ,User(..)
  ,UserStatus(..)
  ,TenantStatus(..))
  where

import Data.Text
import qualified Data.Profunctor.Product.Default as D
import Database.PostgreSQL.Simple.FromField
import Opaleye
       (Constant(Constant), PGText, Column, pgStrictText,
        QueryRunnerColumnDefault(queryRunnerColumnDefault),
        )

data TenantStatus
    = TenantStatusActive 
    | TenantStatusInActive 
    | TenantStatusNew 
    deriving ((((((Show))))))

data Tenant = Tenant
    { tenant_id :: Int
    , tenant_name :: Text
    , tenant_firstname :: Text
    , tenant_lastname :: Text
    , tenant_email :: Text
    , tenant_phone :: Text
    , tenant_status :: TenantStatus
    , tenant_ownerid :: Maybe Int
    , tenant_backofficedomain :: Text
    } deriving ((((((Show))))))

data UserStatus
    = UserStatusActive 
    | UserStatusInActive 
    | UserStatusBlocked 

data User = User
    { user_id :: Int
    , user_tenantid :: Int
    , user_username :: Text
    , user_password :: Text
    , user_firstname :: Maybe Text
    , user_lastname :: Maybe Text
    , user_status :: UserStatus
    } 