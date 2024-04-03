Task: Implement a Concurrent Accessible Expiring Cache System

Objective: design and implement a caching system for caching generic objects. The system must support expiration of cache entries and ensure thread-safe access. The challenge involves not just handling concurrency and memory efficiently, but also dealing with the complexity of expiring data in a way that does not block or slow down concurrent reads for non-expired data.

Requirements:
1. Expiring Cache Entries:
    * Implement a mechanism where each cache entry has an expiration time. After this time, the entry should be considered invalid and not returned to the requester.
    * Cache expiration should be efficiently managed to avoid unnecessary memory use by stale data.
2. Concurrency and Thread Safety:
    * Ensure that the cache can be accessed by multiple threads concurrently without leading to race conditions or corrupt data.
    * Reads for non-expired data should remain fast and not be blocked by writes or expiration checks.
3. Memory Management:
    * Use Swift's memory management features to ensure that cached data does not lead to memory leaks.
    * Implement strategies to limit the memory footprint of the cache.
4. Efficient Data Structures:
    * Choose and/or design data structures that support quick lookups, insertions, and deletions, while also facilitating efficient expiration checks and memory usage.
    * Consider custom collections or extending Swift's existing collections to meet the requirements.
5. Background Expiration Processing:
    * Implement background processing to periodically check for and clear expired cache entries without impacting the main thread or user experience.
    * Use background tasks effectively, ensuring they do not keep the app awake unnecessarily or consume excessive resources.
