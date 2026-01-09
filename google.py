import argparse
import csv
import gzip
import io
import time
from urllib.parse import urlparse
import requests
from bs4 import BeautifulSoup

from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = ["https://www.googleapis.com/auth/webmasters"]

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; index-checker/1.0)"}
TIMEOUT = 30

def fetch(url: str) -> requests.Response:
    r = requests.get(url, headers=HEADERS, timeout=TIMEOUT, allow_redirects=True)
    r.raise_for_status()
    return r

def parse_sitemap(content: bytes, source_url: str):
    # gz destek
    if source_url.endswith(".gz"):
        with gzip.GzipFile(fileobj=io.BytesIO(content)) as gz:
            content = gz.read()

    soup = BeautifulSoup(content, "xml")

    # sitemapindex mi urlset mi?
    if soup.find("sitemapindex"):
        return [], [loc.get_text(strip=True) for loc in soup.find_all("loc")]
    else:
        return [loc.get_text(strip=True) for loc in soup.find_all("loc")], []

def collect_urls_from_sitemaps(sitemaps: list[str], max_sitemaps: int = 300):
    all_urls = set()
    seen = set()
    queue = list(sitemaps)

    while queue and len(seen) < max_sitemaps:
        sm = queue.pop(0)
        if sm in seen:
            continue
        seen.add(sm)

        try:
            r = fetch(sm)
            urls, nested = parse_sitemap(r.content, sm)
            all_urls.update(urls)
            queue.extend([n for n in nested if n not in seen])
        except Exception:
            continue

    return sorted(all_urls)

def build_inspection_service(client_secret_path: str):
    flow = InstalledAppFlow.from_client_secrets_file(client_secret_path, SCOPES)
    creds = flow.run_local_server(port=0)
    return build("searchconsole", "v1", credentials=creds)

def inspect_url(service, site_url: str, page_url: str):
    """
    Returns a tuple: (verdict, coverage_state, last_crawl_time)
    verdict typically: "PASS" (indexed) / "FAIL" / "NEUTRAL" etc.
    """
    body = {
        "inspectionUrl": page_url,
        "siteUrl": site_url
    }
    resp = service.urlInspection().index().inspect(body=body).execute()

    result = resp.get("inspectionResult", {}).get("indexStatusResult", {})
    verdict = result.get("verdict")  # PASS genelde "Indexed"
    coverage = result.get("coverageState")
    last_crawl = result.get("lastCrawlTime")
    return verdict, coverage, last_crawl

def main():
    ap = argparse.ArgumentParser(description="Sitemap URL'lerini al, URL Inspection ile Google indexinde olanları çıkar.")
    ap.add_argument("--client-secret", required=True, help="OAuth client secret json path (Desktop app)")
    ap.add_argument("--site-url", required=True, help="Search Console property, örn: https://dugunkarem.com/ (sonunda / olsun)")
    ap.add_argument("--sitemap", action="append", required=True, help="Sitemap URL (repeatable). Örn: https://.../sitemap.xml")
    ap.add_argument("--sleep", type=float, default=0.2, help="İstek arası bekleme (rate limit yememek için)")
    ap.add_argument("--out", default="indexed_urls.csv", help="Çıktı CSV")
    ap.add_argument("--max", type=int, default=0, help="Test için limit (0=limitsiz)")
    args = ap.parse_args()

    site_url = args.site_url
    if not site_url.endswith("/"):
        site_url += "/"

    urls = collect_urls_from_sitemaps(args.sitemap)
    if args.max and args.max > 0:
        urls = urls[:args.max]

    print(f"[+] Sitemap'ten toplam URL: {len(urls)}")

    service = build_inspection_service(args.client_secret)

    indexed = []
    not_indexed = []
    errors = 0

    for i, u in enumerate(urls, 1):
        try:
            verdict, coverage, last_crawl = inspect_url(service, site_url, u)
            # Basit kural: PASS => indexli say
            if verdict == "PASS":
                indexed.append((u, verdict, coverage, last_crawl))
            else:
                not_indexed.append((u, verdict, coverage, last_crawl))
        except Exception as e:
            errors += 1
            not_indexed.append((u, "ERROR", str(e), ""))

        if i % 25 == 0:
            print(f"  processed {i}/{len(urls)} (indexed={len(indexed)} errors={errors})")

        time.sleep(args.sleep)

    with open(args.out, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["url", "verdict", "coverageState", "lastCrawlTime"])
        for row in indexed:
            w.writerow(row)

    print(f"[+] Indexed URL sayısı: {len(indexed)}")
    print(f"[+] CSV yazıldı: {args.out}")
    if errors:
        print(f"[!] Hata sayısı: {errors} (CSV'de verdict=ERROR olarak görürsün)")

if __name__ == "__main__":
    main()
