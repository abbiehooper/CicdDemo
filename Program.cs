using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

var app = builder.Build();

var startTime = Stopwatch.StartNew();
var requestCount = 0;

app.MapGet("/", () =>
{
    Interlocked.Increment(ref requestCount);
    app.Logger.LogInformation("Request {Count} received", requestCount);

    return new
    {
        Message = "Hello from Azure - Auto Deployed! 🚀",
        Version = Environment.GetEnvironmentVariable("APP_VERSION") ?? "1.0.0",
        Uptime = $"{startTime.Elapsed.TotalSeconds:F0}s",
        RequestCount = requestCount
    };
});

app.MapHealthChecks("/health");

app.MapGet("/ready", () => Results.Ok(new
{
    Status = "ready",
    Timestamp = DateTime.UtcNow
}));

app.Logger.LogInformation("?? Server started on port {Port}",
    Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? "http://localhost:8080");

app.Run();
