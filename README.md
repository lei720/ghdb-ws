## GHDB-WS

GHDB Web Scraper is a Perl script that scrapes the g-dorks 
search terms from a specific expliot-db web page and saves 
them to a file named "results".

The scraper already has a sample of links for different
catagories, just uncomment the one you wish to activate. 

then to start run.

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
a full url ex: http://www.somedomain.com/

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


