# Real-world fixture: ISO 20022 pacs.008.001.09

Sourced from [issettled/iso20022-issettled](https://github.com/issettled/iso20022-issettled)
(Apache License 2.0, see `LICENSE-iso20022-issettled`), a real ISO 20022 FI-to-FI Customer Credit
Transfer schema, unmodified.

- `pacs.008.001.09.xsd` — the schema itself, byte-for-byte as published in that repo.
- `pacs.008.001.09_instance.xml` — a `Document`-rooted instance, not a copy of that repo's own
  example file. Their example wraps the same message inside a proprietary "issettled" envelope
  (a custom `<Message>` root combining a business application header with the payment body) that
  doesn't validate against this schema's own root element. This instance re-wraps the *same real
  field values* (payment amount, dates, debtor/creditor names, BICs, addresses — all copied
  verbatim from their example) in the plain `<Document><FIToFICstmrCdtTrf>...</FIToFICstmrCdtTrf></Document>`
  structure the schema itself declares, with the optional `SplmtryData` blocks (which used an
  `xs:any` wildcard) omitted since they are `minOccurs="0"`.

Used as a real-world stress fixture for `XsdToStruct.jl`'s XSD reader/codegen and
`XmlStructLoader.jl`'s instance loader, alongside this repo's own small synthetic fixtures.
