$Prompt[-1] = {
    if (Test-Success) {
        $heart = "❤", "🧡", "💛", "💚", "💙", "💜", "💔", "💕", "💓", "💗", "💖", "💘", "💝" | Get-Random
    } else {
        $heart = "🧡", "💛", "💙", "🖤" | Get-Random
    }
    New-PromptText "I${heart}PS" -ForegroundColor Black -BackgroundColor White -ErrorForegroundColor White -ErrorBackgroundColor DarkRed
}