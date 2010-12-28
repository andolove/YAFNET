/* Yet Another Forum.net
 * Copyright (C) 2006-2010 Jaben Cargman
 * http://www.yetanotherforum.net/
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
namespace YAF.Core.Services
{
  using System;
  using System.Collections;
  using System.Web;
  using System.Web.Caching;

  using YAF.Core; using YAF.Types.Interfaces; using YAF.Types.Constants;
  using YAF.Utils;
  using YAF.Utils.Helpers.StringUtils;

  /// <summary>
  /// Caching helper class
  /// </summary>
  public class YafCache
  {
    /// <summary>
    /// cache object to work with
    /// </summary>
    private static readonly object[] _lockCacheItems = new object[101];

    /// <summary>
    /// The _cache.
    /// </summary>
    private Cache _cache;

    /// <summary>
    /// default method for creating cache keys
    /// </summary>
    private CacheKeyCreationMethod _keyCreationMethod;

    /// <summary>
    /// Initializes a new instance of the <see cref="YafCache"/> class. 
    /// Default constuctor uses HttpContext.Current as source for obtaining Cache object
    /// </summary>
    public YafCache()
      : this(HttpRuntime.Cache)
    {
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="YafCache"/> class. 
    /// Initializes class with specified Cache object
    /// </summary>
    /// <param name="cache">
    /// Cache to work with
    /// </param>
    public YafCache(Cache cache)
    {
      this._cache = cache;

      // use straigt method as default
      this._keyCreationMethod = CacheKeyCreationMethod.Straight;
    }

    /// <summary>
    /// Gets Current.
    /// </summary>
    [Obsolete("Use YafContext.Current.Cache instead.")]
    public static YafCache Current
    {
      get
      {
        return YafContext.Current.Cache;
      }
    }


    /// <summary>
    /// Indexer for obtaining and setting cache keys
    /// </summary>
    /// <param name="key">Cache key to get or set</param>
    /// <returns>Value cached under specified key</returns>
    public object this[string key]
    {
      get
      {
        return this._cache[CreateKey(key)];
      }

      set
      {
        this._cache[CreateKey(key)] = value;
      }
    }

    /// <summary>
    /// Gets default cache creation method
    /// </summary>
    public CacheKeyCreationMethod KeyCreationMethod
    {
      get
      {
        return this._keyCreationMethod;
      }
 /*set
			{
				_keyCreationMethod = value;
			}*/
    }

    /// <summary>
    /// Gets count of cache keys currently saved.
    /// </summary>
    public int Count
    {
      get
      {
        return this._cache.Count;
      }
    }

    /// <summary>
    /// Creates string to be used as key for caching, board-specific
    /// </summary>
    /// <param name="key">
    /// Key we need to make board-specific
    /// </param>
    /// <returns>
    /// Board sepecific cache key based on key parameter
    /// </returns>
    public static string GetBoardCacheKey(string key)
    {
      // use current YafCache instance as source of board ID
      return GetBoardCacheKey(key, YafContext.Current);
    }

    /// <summary>
    /// Creates string to be used as key for caching, board-specific
    /// </summary>
    /// <param name="key">
    /// Key we need to make board-specific
    /// </param>
    /// <param name="context">
    /// Context from which to determine board ID
    /// </param>
    /// <returns>
    /// Board sepecific cache key based on key parameter
    /// </returns>
    public static string GetBoardCacheKey(string key, YafContext context)
    {
      return GetBoardCacheKey(key, context.PageBoardID);
    }

    /// <summary>
    /// Creates string to be used as key for caching, board-specific
    /// </summary>
    /// <param name="key">
    /// Key we need to make board-specific
    /// </param>
    /// <param name="boardID">
    /// Board ID to use when creating cache key
    /// </param>
    /// <returns>
    /// Board sepecific cache key based on key parameter
    /// </returns>
    public static string GetBoardCacheKey(string key, int boardID)
    {
      return "{0}.{1}".FormatWith(key, boardID);
    }


    /// <summary>
    /// Creates key using default cache key creation method
    /// </summary>
    /// <param name="key">
    /// Key to use for generating cache key
    /// </param>
    /// <returns>
    /// Returns cache key
    /// </returns>
    public string CreateKey(string key)
    {
      // output depends on cache key creation method
      switch (this._keyCreationMethod)
      {
        case CacheKeyCreationMethod.BoardSpecific:

          // return board specific key
          return GetBoardCacheKey(key);
        case CacheKeyCreationMethod.Straight:
        default:

          // return same value as was supplied in parameter
          return key;
      }
    }


    /// <summary>
    /// Adds item to the cache.
    /// </summary>
    /// <param name="key">
    /// Key identifying item in cache.
    /// </param>
    /// <param name="value">
    /// Cached value.
    /// </param>
    /// <param name="dependencies">
    /// Cache dependencies, invalidating cache.
    /// </param>
    /// <param name="absoluteExpiration">
    /// Absolute expiration date. When used, sliding expiration has to be set to Cache.NoSlidingExpiration.
    /// </param>
    /// <param name="slidingExpiration">
    /// Sliding expiration of cache item. When used, absolute expiration has to be set to Cache.NoAbsoluteExpiration.
    /// </param>
    /// <param name="priority">
    /// Relative cost of object in cache. When system evicts objects from cache, objects with lower cost are removed first.
    /// </param>
    /// <param name="onRemoveCallback">
    /// Delegate that is called upon cache item remova. Can be null.
    /// </param>
    /// <returns>
    /// Cached item.
    /// </returns>
    public object Add(
      string key, 
      object value, 
      CacheDependency dependencies, 
      DateTime absoluteExpiration, 
      TimeSpan slidingExpiration, 
      CacheItemPriority priority, 
      CacheItemRemovedCallback onRemoveCallback)
    {
      return this._cache.Add(CreateKey(key), value, dependencies, absoluteExpiration, slidingExpiration, priority, onRemoveCallback);
    }

    /// <summary>
    /// Adds item to the cache.
    /// </summary>
    /// <param name="key">
    /// Key identifying item in cache.
    /// </param>
    /// <param name="value">
    /// Cached value.
    /// </param>
    /// <param name="absoluteExpiration">
    /// Absolute expiration date.
    /// </param>
    /// <returns>
    /// The add.
    /// </returns>
    public object Add(string key, object value, DateTime absoluteExpiration)
    {
      return this._cache.Add(CreateKey(key), value, null, absoluteExpiration, Cache.NoSlidingExpiration, CacheItemPriority.Default, null);
    }


    /// <summary>
    /// Inserts item to the cache.
    /// </summary>
    /// <param name="key">
    /// Key identifying item in cache.
    /// </param>
    /// <param name="value">
    /// Cached value.
    /// </param>
    public void Insert(string key, object value)
    {
      this._cache.Insert(CreateKey(key), value);
    }

    /// <summary>
    /// Inserts item to the cache.
    /// </summary>
    /// <param name="key">
    /// Key identifying item in cache.
    /// </param>
    /// <param name="value">
    /// Cached value.
    /// </param>
    /// <param name="dependencies">
    /// Cache dependencies, invalidating cache.
    /// </param>
    public void Insert(string key, object value, CacheDependency dependencies)
    {
      this._cache.Insert(CreateKey(key), value, dependencies);
    }

    /// <summary>
    /// Inserts item to the cache.
    /// </summary>
    /// <param name="key">
    /// Key identifying item in cache.
    /// </param>
    /// <param name="value">
    /// Cached value.
    /// </param>
    /// <param name="dependencies">
    /// Cache dependencies, invalidating cache.
    /// </param>
    /// <param name="absoluteExpiration">
    /// Absolute expiration date. When used, sliding expiration has to be set to Cache.NoSlidingExpiration.
    /// </param>
    /// <param name="slidingExpiration">
    /// Sliding expiration of cache item. When used, absolute expiration has to be set to Cache.NoAbsoluteExpiration.
    /// </param>
    public void Insert(string key, object value, CacheDependency dependencies, DateTime absoluteExpiration, TimeSpan slidingExpiration)
    {
      this._cache.Insert(CreateKey(key), value, dependencies, absoluteExpiration, slidingExpiration);
    }

    /// <summary>
    /// Inserts item to the cache.
    /// </summary>
    /// <param name="key">
    /// Key identifying item in cache.
    /// </param>
    /// <param name="value">
    /// Cached value.
    /// </param>
    /// <param name="dependencies">
    /// Cache dependencies, invalidating cache.
    /// </param>
    /// <param name="absoluteExpiration">
    /// Absolute expiration date. When used, sliding expiration has to be set to Cache.NoSlidingExpiration.
    /// </param>
    /// <param name="slidingExpiration">
    /// Sliding expiration of cache item. When used, absolute expiration has to be set to Cache.NoAbsoluteExpiration.
    /// </param>
    /// <param name="priority">
    /// Relative cost of object in cache. When system evicts objects from cache, objects with lower cost are removed first.
    /// </param>
    /// <param name="onRemoveCallback">
    /// Delegate that is called upon cache item remova. Can be null.
    /// </param>
    public void Insert(
      string key, 
      object value, 
      CacheDependency dependencies, 
      DateTime absoluteExpiration, 
      TimeSpan slidingExpiration, 
      CacheItemPriority priority, 
      CacheItemRemovedCallback onRemoveCallback)
    {
      this._cache.Insert(CreateKey(key), value, dependencies, absoluteExpiration, slidingExpiration, priority, onRemoveCallback);
    }


    /// <summary>
    /// Removes specified key from cache
    /// </summary>
    /// <param name="key">
    /// Key to remove
    /// </param>
    /// <returns>
    /// Value removed from cache, null if no such key was cached
    /// </returns>
    public object Remove(string key)
    {
      return this._cache.Remove(CreateKey(key));
    }

    /// <summary>
    /// Removes all keys for which given predicate returns true.
    /// </summary>
    /// <param name="predicate">
    /// Predicate for matching cache keys.
    /// </param>
    public void Remove(Predicate<string> predicate)
    {
      // get enumarator
      IDictionaryEnumerator key = this._cache.GetEnumerator();

      // cycle through cache keys
      while (key.MoveNext())
      {
        // remove cache item if predicate returns true
        if (predicate(key.Key.ToString()))
        {
          this._cache.Remove(key.Key.ToString());
        }
      }
    }

    /// <summary>
    /// Removes all cache items that start with the string.
    /// </summary>
    /// <param name="startsWith">
    /// </param>
    public void RemoveAllStartsWith(string startsWith)
    {
      Remove(x => x.StartsWith(startsWith));
    }

    /// <summary>
    /// Clear all cache entries from memory.
    /// </summary>
    public void Clear()
    {
      // get enumarator
      IDictionaryEnumerator key = this._cache.GetEnumerator();

      // cycle through cache keys
      while (key.MoveNext())
      {
        // and remove them one by one
        this._cache.Remove(key.Key.ToString());
      }
    }

    /// <summary>
    /// Gets the cached item as a specific type.
    /// </summary>
    /// <typeparam name="T">
    /// </typeparam>
    /// <param name="key">
    /// </param>
    /// <returns>
    /// </returns>
    public T GetItem<T>(string key) where T : class
    {
      if (this[key] != null)
      {
        return (T) this[key];
      }

      return null;
    }

    /// <summary>
    /// Gets the cached item as a specific type but if the item doesn't exist or 
    /// is expired, will pull a new value from the function provided.
    /// </summary>
    /// <typeparam name="T">
    /// </typeparam>
    /// <param name="key">
    /// </param>
    /// <param name="expireMilliseconds">
    /// </param>
    /// <param name="getValue">
    /// </param>
    /// <returns>
    /// </returns>
    public T GetItem<T>(string key, double expireMilliseconds, Func<T> getValue) where T : class
    {
      return GetItem<T>(key, expireMilliseconds, CacheItemPriority.Default, getValue);
    }

    /// <summary>
    /// Gets the cached item as a specific type but if the item doesn't exist or 
    /// is expired, will pull a new value from the function provided.
    /// </summary>
    /// <typeparam name="T">
    /// </typeparam>
    /// <param name="key">
    /// </param>
    /// <param name="expireMinutes">
    /// </param>
    /// <param name="getValue">
    /// </param>
    /// <returns>
    /// </returns>
    public T GetItem<T>(string key, int expireMinutes, Func<T> getValue) where T : class
    {
      return GetItem<T>(key, expireMinutes, CacheItemPriority.Default, getValue);
    }

    /// <summary>
    /// The get item.
    /// </summary>
    /// <param name="key">
    /// The key.
    /// </param>
    /// <param name="expireMinutes">
    /// The expire minutes.
    /// </param>
    /// <param name="priority">
    /// The priority.
    /// </param>
    /// <param name="getValue">
    /// The get value.
    /// </param>
    /// <typeparam name="T">
    /// </typeparam>
    /// <returns>
    /// </returns>
    public T GetItem<T>(string key, int expireMinutes, CacheItemPriority priority, Func<T> getValue) where T : class
    {
      return GetItem<T>(key, expireMinutes*60000d, CacheItemPriority.Default, getValue);
    }

    /// <summary>
    /// Gets the cached item as a specific type but if the item doesn't exist or 
    /// is expired, will pull a new value from the function provided.
    /// </summary>
    /// <typeparam name="T">
    /// </typeparam>
    /// <param name="key">
    /// </param>
    /// <param name="expireMilliseconds">
    /// </param>
    /// <param name="priority">
    /// </param>
    /// <param name="getValue">
    /// </param>
    /// <returns>
    /// </returns>
    public T GetItem<T>(string key, double expireMilliseconds, CacheItemPriority priority, Func<T> getValue) where T : class
    {
      int keyHash = key.GetHashCode();

      // make positive if negative...
      if (keyHash < 0)
      {
        keyHash = -keyHash;
      }

      // get the lock item id (value between 0 and 100)
      int lockItemId = keyHash%100;

      // init the lock object if it hasn't been created yet...
      if (_lockCacheItems[lockItemId] == null)
      {
        _lockCacheItems[lockItemId] = new object();
      }

      var cachedItem = GetItem<T>(key);

      if (cachedItem == null)
      {
        lock (_lockCacheItems[lockItemId])
        {
          // now that we're on lockdown, try one more time...
          cachedItem = GetItem<T>(key);

          if (cachedItem == null)
          {
            // just get the value from the passed function...
            cachedItem = getValue();

            if (cachedItem != null)
            {
              // cache the new value...
              Add(key, cachedItem, null, DateTime.UtcNow.AddMilliseconds(expireMilliseconds), Cache.NoSlidingExpiration, priority, null);
            }
          }
        }
      }

      return cachedItem;
    }
  }


  /// <summary>
  /// Enumeration of methods for generating cache keys
  /// </summary>
  public enum CacheKeyCreationMethod
  {
    /// <summary>
    /// The straight.
    /// </summary>
    Straight, 

    /// <summary>
    /// The board specific.
    /// </summary>
    BoardSpecific
  }
}