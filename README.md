## GHDB-WS

GHDB Web Scraper is a Perl script that scrapes the g-dorks 
search terms from a specific expliot-db web page and saves 
them to a file named "results".

The scraper already has a sample of links for different
categories, just uncomment the one you wish to activate. 

When uncommenting one of the URLs you will only receive the 
most recently archived Google dorks. To get everything from 
a specific category you need to understand the link 
structure. 

Each category page has a query at the of the specific 
category “?pg=1” meaning page one.

The query being “?pg” and the value is equal to the page 
number “=1 or =2 or =3”

Create a list of the desired URLs to download the entire
dorks from a category.

To start, run.

```
user@blah:~# ./ghdb-ws.pl
```
	
### Important Details 

Perl Modules required

* LWP::UserAgent --------> should be part of core modules 
* HTML::LinkExtor
* HTML::Selector::XPath
* HTML::TreeBuilder::XPath

To make installation easy use the cpanminus package
manager.

You have the option to comment out or add URLs, insure it's
a full url.
```
ex: http://www.example-domain.com/
```

If you have problems using LWP::UserAgent with a SOCKS Proxy
you more than likely need to install the LWP::Protocol::socks
module.

This script will wait a minute between each page
request in order to prevent any abuse of server 
resources.

So if it's slow, know that it's a feature and leave the 
code responsible for this as it is.


xor-function = null
@nighowlconsulting.com


