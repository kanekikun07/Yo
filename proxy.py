
import requests

def fetch_proxies():
    url = "https://proxylist.geonode.com/api/proxy-list"
    params = {
        "limit": 500,
        "page": 1,
        "sort_by": "lastChecked",
        "sort_type": "desc"
    }

    response = requests.get(url, params=params)
    response.raise_for_status()
    data = response.json()

    proxies = []
    for proxy in data.get("data", []):
        # Some proxies may not have all fields, so be careful
        protocol = proxy.get("protocols", [""])[0].lower() if proxy.get("protocols") else ""
        ip = proxy.get("ip")
        port = proxy.get("port")
        if protocol and ip and port:
            proxies.append(f"{protocol}://{ip}:{port}")

    return proxies

def main():
    proxies = fetch_proxies()
    with open("proxies.txt", "w") as f:
        for proxy in proxies:
            f.write(proxy + "\n")
    print(f"Scraped {len(proxies)} proxies into proxies.txt")

if __name__ == "__main__":
    main()
