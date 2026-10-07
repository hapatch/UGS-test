using System;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

// This is a prototyped class to showcase the functionality for querying a Shared DDC location
// This allows us to potentially assist users who may be starting up the editor or performing actions that may be slow without a working DDC

namespace UnrealGameSync
{

	public enum DdcReachability
	{
		NotConfigured,
		Reachable,
		Unreachable,
	}

	public class DdcCheckResult
	{
		public string? ServerUrl { get; init; }
		public DdcReachability Reachability { get; init; }
	}

	public static class DerivedDataCacheChecker
	{
		// Showcase an environment variable set way to retrieve a DDC url to check
		const string OverrideEnvironmentVariable = "UGS_DDC_SERVER_URL_OVERRIDE";

		public static async Task<DdcCheckResult> CheckAsync(ILogger logger, CancellationToken cancellationToken)
		{
			// Just as an example 
			// string? serverUrl = Environment.GetEnvironmentVariable(OverrideEnvironmentVariable);
			// Force set a serverUrl for testing
			string? serverUrl = "SomeFakeURL";
			if (String.IsNullOrEmpty(serverUrl))
			{
				return new DdcCheckResult { ServerUrl = null, Reachability = DdcReachability.NotConfigured };
			}

			bool reachable = await TryConnectAsync(serverUrl, logger, cancellationToken);
			return new DdcCheckResult { ServerUrl = serverUrl, Reachability = reachable ? DdcReachability.Reachable : DdcReachability.Unreachable };
		}

		// Simulate an attempt to connect to a DDC URL. 
		static async Task<bool> TryConnectAsync(string serverUrl, ILogger logger, CancellationToken cancellationToken)
		{
			logger.LogInformation("Checking shared DDC server reachability: {ServerUrl}", serverUrl);
			return false; // always fails - POC only
		}
	}
}
