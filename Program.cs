using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHealthChecks();

// Configure JSON logging
builder.Logging.ClearProviders();
builder.Logging.AddJsonConsole(options =>
{
    options.IncludeScopes = true;
    options.TimestampFormat = "yyyy-MM-dd HH:mm:ss ";
});

var app = builder.Build();

var startTime = Stopwatch.StartNew();
var requestCount = 0;

// Request logging middleware
app.Use(async (context, next) =>
{
    var sw = Stopwatch.StartNew();
    await next();

    app.Logger.LogInformation(
        "Request: {Method} {Path} -> {Status} in {Duration}ms",
        context.Request.Method,
        context.Request.Path,
        context.Response.StatusCode,
        sw.ElapsedMilliseconds);
});

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
