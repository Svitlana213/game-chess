using ChessServer;
using ChessServer.Properties;
using Microsoft.AspNetCore.SignalR;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSignalR();
builder.Services.AddSingleton<Game>();

var app = builder.Build();

app.UseHttpsRedirection();

app.MapHub<ChessHub>("/chessHub");

app.Run();

public class ChessHub(Game game, ILogger<ChessHub> logger) : Hub
{
    private readonly List<Room> _rooms = game.Rooms;
    private ILogger<ChessHub> _logger = logger;

    public async Task CreateGame(string name)
    {
        var r = new Room(name)
        {
            User1 = Context.ConnectionId
        };
        
        _rooms.Add(r);
        
        await Groups.AddToGroupAsync(Context.ConnectionId, name);
        
        _logger.LogInformation($"CreateGame {r}");
    }

    public async Task ConnectGame(string name)
    {
        var r = _rooms.First(x => x.GameName == name);
        r.User2 = Context.ConnectionId;
        
        await Groups.AddToGroupAsync(Context.ConnectionId, name);
        
        _logger.LogInformation($"ConnectGame {r}");
    }
    
    public IEnumerable<string> GetGameList()
    { 
        var rooms = _rooms
            .Where(x => string.IsNullOrEmpty(x.User2))
            .Select(x => x.GameName)
            .ToList();
        
        _logger.LogInformation($"GetGameList {string.Join(", ", rooms)}");

        return rooms;
    }

    public async Task Move()
    {
        
    }
}