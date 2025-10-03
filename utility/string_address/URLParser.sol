// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IURLParser {
    struct ParsedURL {
        string scheme;
        string host;
        string path;
        string query;
        string fragment;
    }

    event URLParsed(string indexed originalURL, string indexed host);

    error InvalidURL(string url);

    function parseURL(string memory _url) external pure returns (ParsedURL memory);
    function isValidURL(string memory _url) external pure returns (bool);
}