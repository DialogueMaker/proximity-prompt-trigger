--!strict
-- Automatically triggers the dialogue server when the player touches a prompt region.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");

local packages = script.Parent.roblox_packages;
local IClient = require(packages.client_types);
local IConversation = require(packages.conversation_types);

type Client = IClient.Client;
type Conversation = IConversation.Conversation;

return function(client: Client)

  for _, conversationModuleScript in CollectionService:GetTagged("DialogueMaker_Conversation") do

    local didInitialize, errorMessage = pcall(function()

      -- We're using pcall because require can throw an error if the module is invalid.
      local conversation = require(conversationModuleScript) :: Conversation;
      local conversationSettings = conversation:getSettings();
      local proximityPrompt = conversationSettings.proximityPrompt.instance;
      if conversationSettings.proximityPrompt.shouldAutoCreate then

        local autoCreatedProximityPrompt = Instance.new("ProximityPrompt");
        autoCreatedProximityPrompt.Parent = conversation.moduleScript.Parent;
        proximityPrompt = autoCreatedProximityPrompt;

      end;

      if proximityPrompt then

        proximityPrompt.Triggered:Connect(function()

          proximityPrompt.Enabled = false;
          client:interact(conversation);

        end);

        client.ConversationChanged:Connect(function()

          if client:getConversation() == nil then

            proximityPrompt.Enabled = true;

          else

            proximityPrompt.Enabled = false;

          end;

        end);

      end;

    end);

    if not didInitialize then

      local fullName = conversationModuleScript:GetFullName();
      warn(`[Dialogue Maker] Failed to initialize proximity prompt for {fullName}: {errorMessage}`);

    end;

  end;

end;