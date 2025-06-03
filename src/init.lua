--!strict
-- Automatically triggers the dialogue server when the player touches a prompt region.
--
-- Programmers: Christian Toney (Christian_Toney)
-- © 2023 – 2025 Dialogue Maker Group

local CollectionService = game:GetService("CollectionService");

local packages = script.Parent.roblox_packages;
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type Client = DialogueMakerTypes.Client;
type Conversation = DialogueMakerTypes.Conversation;

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

          local dialogue = conversation:findNextVerifiedDialogue();
          if dialogue then

            proximityPrompt.Enabled = false;
            client:setDialogue(dialogue);

          end;

        end);

        client.DialogueChanged:Connect(function()

          proximityPrompt.Enabled = client:getDialogue() == nil;

        end);

      end;

    end);

    if not didInitialize then

      local fullName = conversationModuleScript:GetFullName();
      warn(`[Dialogue Maker] Failed to initialize proximity prompt for {fullName}: {errorMessage}`);

    end;

  end;

end;