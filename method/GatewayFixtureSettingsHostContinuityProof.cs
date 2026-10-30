using System.Windows.Automation;
using OpenClaw.GatewayFixtureHost;
using OpenClaw.TestSupport.Gateway;

namespace OpenClaw.Tray.UITests;

// Proof harness for PR #1795, copied into the guest checkout only (not part of the PR).
// Drives the retained Settings host inside the Workspace window across a held/released
// roster reconnect, then returns to chat and sends through the ordinary composer.
public sealed partial class GatewayFixtureUiTests
{
    [GatewayFixtureUiFact]
    [Trait("Category", "SettingsHostContinuityProof")]
    public async Task Proof_SettingsHostKeepsAssistantAndConversationAcrossReconnect()
    {
        await WithAppAsync(async run =>
        {
            await run.InvokeAsync("app.navigate", new { page = "chat" });
            await SelectSessionAsync(run, GatewayScenario.OtherSessionTitle, GatewayScenario.OtherSessionKey);
            await WaitUiAsync(run, () => AssistantSelected(run, "research"), "explicit research assistant");
            SettingsProofCapture(run, "settings-host-1-chat-selected.png");

            await run.InvokeAsync("app.navigate", new { page = "settings" });
            await WaitUiAsync(run, () => FindById(run, "SettingsPageMarker") is { Current.IsOffscreen: false },
                "Settings shown in the Workspace window");
            Assert.Single(AppWindows(run));
            SettingsProofCapture(run, "settings-host-2-settings-open.png");

            var occurrence = run.Gateway.Requests.Count(request => request.Method == "agents.list") + 1;
            run.Gateway.HoldAgentsList();
            try
            {
                await run.Gateway.CloseConnectionsAsync();
                await run.Gateway.WaitForRequestAsync("agents.list", occurrence: occurrence);
                SettingsProofCapture(run, "settings-host-3-reconnect-roster-held.png");
            }
            finally
            {
                run.Gateway.ReleaseAgentsList();
            }

            await run.InvokeAsync("app.navigate", new { page = "chat" });
            await WaitUiAsync(run, () => FindById(run, "ChatComposerInput") is { Current.IsOffscreen: false } &&
                AssistantSelected(run, "research") && SessionSelected(run, GatewayScenario.OtherSessionTitle),
                "chat restored with the same assistant and conversation after Settings and reconnect");
            Assert.Single(AppWindows(run));
            SettingsProofCapture(run, "settings-host-4-chat-restored.png");

            const string prompt = "Fixture send after Settings and reconnect.";
            ((ValuePattern)FindById(run, "ChatComposerInput")!.GetCurrentPattern(ValuePattern.Pattern)).SetValue(prompt);
            await WaitUiAsync(run, () => FindById(run, "ChatComposerPrimaryAction") is
                { Current.IsEnabled: true, Current.Name: "Send" }, "native Send action");
            Invoke(FindById(run, "ChatComposerPrimaryAction")!);
            var sent = await run.Gateway.WaitForCompletedRequestAsync("chat.send", GatewayScenario.OtherSessionKey);
            Assert.Equal("ok", sent.Outcome);
            SettingsProofCapture(run, "settings-host-5-sent.png");
            File.WriteAllLines(Path.Combine(Environment.GetEnvironmentVariable("OPENCLAW_GATEWAY_FIXTURE_ARTIFACTS")!,
                "settings-host-gateway-requests.txt"), run.Gateway.Requests.Select(request =>
                    $"{request.Method} session={request.SessionKey ?? "-"} outcome={request.Outcome}"));
        }, scenario: GatewayScenario.CreateBrowse(requireAgentSelection: true, allowChatSend: true));
    }

    private static void SettingsProofCapture(GatewayFixtureRun run, string name) =>
        OwnedWindowCapture.Save(run, AppWindows(run).OrderByDescending(window =>
            window.Current.BoundingRectangle.Width * window.Current.BoundingRectangle.Height).First(), name,
            new[] { "SettingsPageMarker", "WorkspaceAssistantSelector", "WorkspaceNavHome", "ChatComposerInput" }
                .Select(id => FindById(run, id)).Where(element => element is { Current.IsOffscreen: false })
                .Cast<AutomationElement>().ToArray());
}