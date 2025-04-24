// Para Program.cs en .NET 6+
var builder = WebApplication.CreateBuilder(args);

// Instalar primero el paquete NuGet: Elastic.Apm.NetCoreAll
builder.Services.AddElasticApm(builder.Configuration);

// Resto de la configuración...
var app = builder.Build();

// Para Startup.cs en versiones anteriores de .NET Core
// public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
// {
//     // Agregar middleware APM
//     app.UseElasticApm(Configuration);
//     
//     // resto de la configuración...
// }