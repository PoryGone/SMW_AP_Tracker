
function BowserCost()
	local currentTokens = Tracker:ProviderCountForCode("boss_tokens")
	local requiredTokens = Tracker:ProviderCountForCode("bosses_required")
	return (currentTokens >= requiredTokens)
end
