{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeSynonymInstances #-}

module IHaskell.Display.Widgets.String.Latex (
    -- * The Latex Widget
    LatexWidget,
    -- * Constructor
    mkLatexWidget,
    ) where

-- To keep `cabal repl` happy when running from the ihaskell repo
import           Prelude

import           Control.Monad (when, join)
import           Data.Aeson
import           Data.IORef (newIORef)
import           Data.Text (Text)
import           Data.Vinyl (Rec (..), (<+>))

import           IHaskell.Display hiding (Widget)
import           IHaskell.Eval.Widgets
import           IHaskell.IPython.Message.UUID as U

import           IHaskell.Display.Widgets.Types

-- | A 'LatexWidget' represents a Latex widget from IPython.html.widgets.
type LatexWidget = Widget LatexType

-- | Create a new Latex widget
mkLatexWidget :: IO LatexWidget
mkLatexWidget = do
  -- Default properties, with a random uuid
  uuid <- U.random
  let widgetState = WidgetState $ defaultStringWidget "LatexView"

  stateIO <- newIORef widgetState

  let widget = Widget uuid stateIO
      initData = object ["model_name" .= str "WidgetModel", "widget_class" .= str "IPython.Latex"]

  -- Open a comm for this widget, and store it in the kernel state
  widgetSendOpen widget initData $ toJSON widgetState

  -- Return the widget
  return widget

instance IHaskellDisplay LatexWidget where
  display b = do
    widgetSendView b
    return $ Display []

instance IHaskellWidget LatexWidget where
  getCommUUID = uuid
