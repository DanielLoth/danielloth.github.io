---
title: Expand and contract online schema change
layout: post
tags: ["SQL Server", "online schema change", "zero downtime"]
date: "2023-02-02"
---

One of the more interesting parts of my job is that the company I work for offers software that runs on a 24/7 basis. This is markedly different from a lot of other companies, because it means that we strive to avoid outages at all costs.

This is on a best-effort basis of course, aspirational. But as a rule, we don't _plan_ to take an outage. If one does occur, it's almost certainly unplanned and unintended.

That means no Friday evening outage after close of business, and no outage at 4am on a Saturday morning (which seems to be favoured by the banking sector within Australia).

## Prior art

A fair bit has been said about online schema change elsewhere.

One rather prominent example is [Michael J Swart - Modifying Tables Online](https://michaeljswart.com/2012/04/modifying-tables-online-part-1-migration-strategy/).

Sadly, Michael's solution places one in a position where they've moved the problem from one place (being able to add a `rowversion` column online) to another (being able to check the newly created constraints online so that SQL Server deems them trustworthy).

Now does it matter if you can never have SQL Server deem those constraints trustworthy? A bit.

It can have a material impact on SQL Server's query planning because it doesn't know - can't know - that the content subject to constraint is in fact in harmony with that constraint.

The 'Expand and Contract' pattern is also quite well-covered.

For example, it's covered in [Prisma's Data Guide - Using the expand and contract pattern for schema changes](https://www.prisma.io/dataguide/types/relational/expand-and-contract-pattern)

However, I've not yet seen someone cover the subject matter with a concrete follow-along-at-home example.

A crucial benefit of expand and contract - as described in Prisma's Data Guide - is that it allows you to defer one-way door decisions until very late in the process. In fact, even after committing to the new structure you are afforded the ability to revert back to the original structure.

This benefit is absent in Michael's blog. Admittedly, it's probably an unnecessary feature for something like adding a `rowversion` column.

## Online schema change

Online schema change as a concept simply means the ability to make alterations to the structure of your schema while other database users are simultaneously transacting against the data.

When it comes to SQL Server, this is arguably one of the killer features of Enterprise Edition.

You can do quite a bit of schema change online with Enterprise Edition.

Working with the `StackOverflow2010` database, let's first make one change to the primary key constraint - enabling page-level compression on the clustered index.

We'll fatten the table up a bit as well with a `Filler` column so that each row is wider on disk and in RAM.

```sql
alter table dbo.Votes drop
	constraint if exists PK_Votes__Id,
	constraint if exists DF_Votes_Filler,
	column if exists Filler;

-- This will take a little bit of time.
alter table dbo.Votes add
	Filler char(2000) not null
		constraint DF_Votes_Filler default replicate(newid(), 20);

alter table dbo.Votes add
	constraint PK_Votes__Id primary key clustered (Id)
	with (data_compression = page);
```

And now we can happily run all of the following queries instantly:

```sql
alter table dbo.Votes drop
	constraint if exists DF1,
	constraint if exists DF2,
	constraint if exists DF3,
	column if exists C1,
	column if exists C2,
	column if exists C3;

-- Instant, metadata-only
alter table dbo.Votes add C1 int null;

-- Instant, metadata-only
alter table dbo.Votes alter column C1 bigint null
    with (online = on);

-- Instant, metadata-only
alter table dbo.Votes add C2 int not null
    constraint DF2 default 0;

-- Instant, metadata-only
alter table dbo.Votes add C3 int not null
    constraint DF3 default 0;

-- Drop so we can widen column.
-- (Don't worry, Microsoft is gracious enough to let you drop things instantly - even in Express Edition)
alter table dbo.Votes drop
    constraint if exists DF3;

-- Instant, metadata-only
alter table dbo.Votes alter column C3 bigint not null
    with (online = on);
```

And that's not on an empty table. The `dbo.Votes` table within the `StackOverflow2010` database contains over 10 million records. And with our newly added, compression-avoidant, `Filler` column it weighs in at about 8GB.

Of course, this would be cold comfort to anyone ambitiously pursuing zero downtime schema change on Standard Edition.

## The missing pieces

But Enterprise Edition, even 2022, still has its limits.

For example, consider the following:

```sql
alter table dbo.Votes drop
    column if exists DataVersion,
    constraint if exists CK_Votes_AlwaysTrue;

-- Adding a rowversion cannot be achieved with an online or metadata-only change.
alter table dbo.Votes add
    DataVersion rowversion not null;

-- Runs instantly... But leaves the constraint untrusted.
alter table dbo.Votes with nocheck add
    constraint CK_Votes_AlwaysTrue check (1=1);

-- And checking a CHECK constraint to make it trustworthy
-- cannot be done online.
-- Checking a FOREIGN KEY constraint poses the same challenge.
alter table dbo.Votes with check
    check constraint CK_Votes_AlwaysTrue;
```
