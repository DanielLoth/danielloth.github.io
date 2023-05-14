---
title: Database ASBO culture
layout: post
tags: ["SQL Server", "T-SQL", "timestamp", "rowversion"]
date: "2022-10-29"
---

Let's talk about [ASBO](https://en.wikipedia.org/wiki/Anti-social_behaviour_order) culture amongst database transactions, and how it can manifest due to a somewhat popular developer maxim that *it's easier to ask for forgiveness than permission* as opposed to the notion of *look before you leap*.

The idea is simple enough: Why check that you're in the right place, at the right time, when you can merely attempt something and let the system rebuff your request if you're in the wrong?

This has been discussed tangentially before over the years in the context of upsert logic.

[Michael J Swart](https://michaeljswart.com) has published a few blog posts concerning the merits of ideas like [JFDI (Feb 2016)](https://michaeljswart.com/2016/02/ugly-pragmatism-for-the-win/) and later followed up with a post concerning [SQL Server upsert patterns and antipatterns (Jul 2017)](https://michaeljswart.com/2017/07/sql-server-upsert-patterns-and-antipatterns/).

[Aaron Bertrand](https://sqlperformance.com/author/abertrand) has also posted his own article calling on SQL developers to [please stop using this UPSERT anti-pattern (Sep 2020)](https://sqlperformance.com/2020/09/locking/upsert-anti-pattern).

Aaron's article points out the needlessness of checking for row existence prior to either inserting or updating a row:

> Locating the row to confirm it exists, only to have to locate it again in order to update it, is doing twice the work for nothing.

And in the context of upsert logic it's correct because updating the row (or at least attempting to update the row) implies an existence check in that you can establish whether or not the update affected one row or zero rows.

But what if you take the same approach to something like lost update protection?

## Notes

Aaron has another post that compares and contrasts [error handling approaches](https://sqlperformance.com/2012/08/t-sql-queries/error-handling) including *look before you leap*. It's a good read.



-----

```sql
drop table if exists Person;
go
create table person (
	person_id int primary key,
	first_name nvarchar(100) not null,
	rv rowversion not null,
	rvi as isnull(cast(rv as bigint), 0)
);
go

insert into person (person_id, first_name)
values (1, 'Bob');

declare @stale_concurrency_token bigint = 1;

set transaction isolation level serializable;
begin transaction;

update person
set first_name = 'Robert'
where person_id = 1
and rvi = @stale_concurrency_token;

--rollback;

---------

--use tempdb;

--select * from person;
```
