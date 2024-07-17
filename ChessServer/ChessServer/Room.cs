namespace ChessServer;

public record Room(string GameName)
{
    public string? User1 { get; set; }
    public string? User2 { get; set; }
    
}