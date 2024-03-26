# Backend coding challenge

## Up and running

You will need [Docker](https://docs.docker.com/engine/install/) to run this project.

Go to the directory where the project is stored:

```bash
cd <path/to/project>
```

Build and start the project:

```bash
make start
```

Create databases:

```bash
make db-create
```

Check the `config/database.yml` file exists in case of failure. If does not exist, run following command:

```bash
cp config/database.yml{.sample,}
```

And try again.

There are two Rake tasks that allow to import merchants and orders, executed under the hood with following command:

```bash
$ make db-import-data
```

The process to import +1.3M orders is a secure but slow process, so I'd recommend to restore the dump that is available on [this link](https://drive.google.com/file/d/1oLBTDV3YAqM8Eicm9yGp2vvMQ1jUPKq0/view?usp=sharing) and store it in `db/dump.sql`. I'll give some details about that process later.

Restore database:

```bash
$ make db-restore
```

Run migrations, if needed:

```bash
$ make db-migrate APP_ENV=<environment>
```

Run test suite:

```bash
$ make test
```

Run unit tests:

```bash
$ make test-unit
```

Run tests that hit the database:

```bash
$ make test-database
```

Run linter:

```bash
$ make lint
```

Take a look at `Makefile` to see other commands available.

## Code

The code in this challenge has been highly inspired by [Codely](https://codely.com/) and [Upgrow](https://github.com/backpackerhh/upgrow-docs) by Shopify.

Therefore, you will find here an application slightly different to a classical Rails application, especially in the way logic is organized and how is tested. More details in following sections.

Disclaimer: I'm aware that this approach is overkill for a mini project like this, but the goal was showing how could be done for projects way bigger, aiming for maintainability, scalability and testability.

### Technical choices

In every case, I'm using the latest stable version at the moment of writing.

#### Programming language

[Ruby 3.3.0](https://www.ruby-lang.org/en/news/2023/12/25/ruby-3-3-0-released/)

#### Framework

[Rails 7.1.3.2](https://rubyonrails.org/2024/2/21/Rails-Versions-6-1-7-7-7-0-8-1-and-7-1-3-2-have-been-released)

#### Database

[PostgreSQL 16](https://www.postgresql.org/docs/release/16.2/)

#### Background jobs

[Sidekiq 7](https://www.mikeperham.com/2022/10/27/introducing-sidekiq-7.0/)

#### Containers

[Docker 24](https://docs.docker.com/engine/release-notes/24.0/#2409) + [docker compose 2](https://docs.docker.com/compose/release-notes/#2260)

#### Dependencies

[money](https://github.com/Rubymoney/money) and [money-rails](https://github.com/RubyMoney/money-rails) to deal with money.

[SmarterCSV](https://github.com/tilo/smarter_csv) to efficiently work with CSV files.

[whenever](https://github.com/javan/whenever/) to work with cron jobs.

[dry-struct](https://dry-rb.org/gems/dry-struct) and [dry-types](https://dry-rb.org/gems/dry-types) from the great [dry-rb](https://dry-rb.org/) project.

Check the `Gemfile` for more dependencies for development and test environments.

I've tried to keep external dependencies to a minimum. Every time a new dependency has been added, details about it were included in the relevant commit.

### Design

#### Domain-Driven Design (DDD)

The **strategical design** can't be properly applied here without access to *domain experts*.

That means that there is no *ubiquitous language* defined as such, so I've used the names specified in the instructions.

As this challenge is about implementing the process of paying merchants, I decided to create a bounded context named **payments** (namespace **PaymentsContext**) where all the specific logic is placed. That way, if a module named *payments* is added at some point later, we avoid any confusion or even name collision. It's probably a name too generic, but for the sake of this challenge I thought is good enough.

There is another bounded context named **shared** (namespace **SharedContext**) that includes all the logic that could be reused among multiple bounded contexts.

```
├── app
│   └── contexts
│       ├── payments_context
│       │   ├── disbursements
│       │   │   ├── entities
│       │   │   │   └── disbursement_entity.rb
│       │   │   ├── jobs
│       │   │   │   ├── create_disbursement_job.rb
│       │   │   │   └── generate_disbursements_job.rb
│       │   │   ├── ...
│       │   ├── merchants
│       │   │   ├── entities
│       │   │   │   └── merchant_entity.rb
│       │   │   ├── jobs
│       │   │   │   ├── create_merchant_job.rb
│       │   │   │   └── import_merchants_job.rb
│       │   │   ├── ...
│       │   ├── ...
│       └── shared_context
│           ├── entities
│           │   └── aggregate_root.rb
│           ├── errors
│           │   ├── duplicated_record_error.rb
│           │   ├── invalid_argument_error.rb
│           │   └── record_not_found_error.rb
│           ├── ...
```

Currently there is no module *shared* inside *payments* context.

I've applied the **tactical design** in this challenge making use of the following building blocks:

* **Entities** and **value objects** to define *aggregates*, with their respective *aggregate root*.
* **Domain services** to reuse some domain logic and/or inject them in other collaborator objects.
* **Factories** to encapsulate the creation of entities both in production and test code.
* **Application services** to represent *use cases*.
* **Repositories** to interact with external resources.

Due to time constraints I haven't implemented **domain events** here. However, it'd resolve some coupling issues in the code, where a job from another module has been used instead of publishing an event and having n event subscribers listening. Of course, adding an event bus to the system adds another set of complexities, but that's a topic for another time.

I have added a comment with FIXME in those places where it could be fixed.

#### Architecture

I haven't implemented explicitly any kind of architecture in this challenge, such as *hexagonal architecture* (ports and adapters), but I tried to imagine that each type of file belongs to a different layer and avoid that inner layers couldn't reference code from outer layers.

```
app/contexts/<bounded context>/<module>/<entities,use_cases,repositories...>
```

Next I'm gonna explain some details about each type of file that you can find in the code.

A **record** (model in a classic Rails application) is limited here to define the associated table in the database, define alias for some attributes and specify which columns represent money. That is, no associations, domain logic nor validations are included.

An **entity** is what Shopify calls [model](https://github.com/backpackerhh/upgrow-docs/blob/main/guide/6-the-missing-pieces.md#models), but I prefer to avoid any kind of confusion with what is usually called model in Rails. Here is where the domain logic resides. Each of its attributes is represented by a **value object**, instead of a primitive such as integer, string or boolean. This part is clearly borrowed from Codely.

The factory method *.from_primitives* is used to load an entity for the first time using given values or restore it from the persistence layer, usually a database.

The method *#to_primitives* is used to transfer data (DTO).

A **value object** only includes a *value* attribute and is responsible for validating the correct value is provided on initialization.

The approach of having a value object per attribute comes with the cost of having way more files than usual, but I think it's worth it.

A **domain service** represents a stateless operation that can be reused in different parts of the application and/or injected to other objects, usually in different modules of the same context.

A **factory** works here as a wrapper of the factory defined with [FactoryBot](https://github.com/thoughtbot/factory_bot) in test environment, so you'll find them inside the *spec* directory. The only references to FactoryBot live inside these wrappers, that build or create and instance of the record and return an instance of the entity. Every attribute of the entity has its own value object factory too.

A **use case** is an *application service*, that orchestrates some action and does not return a value. In this challenge, every use case receives a set of attributes, build an entity and provides the data to the repository received via the constructor that will persist it.

Although not implemented here, usually, some domain event would be published after the action has finished.

A **repository** is the façade with the ORM, I/O or other external services. In this challenge no other reference to ActiveRecord methods is found outside a repository.

Being that way, replacing the persistence service (e.g. MySQL with Postgres) or even the ORM (e.g. ActiveRecord with Sequel) would be transparent to the rest of the application, except for the record, where at least the superclass would change.

A **job** performs an action in the background, usually receiving via the constructor a domain service or a use case.

An **error** is a custom exception that is usually raised from a repository. Its name is always more semantic than the original exception raised.

### Testing

In this challenge I've followed as much as possible an **Outside-In Test-Driven Development** approach, with the same *red, green, refactor* steps than TDD, but starting from the outside of the application and going inwards.

In short, the process is something like this:

* Add an acceptance test, that should be failing for the expected reason, e.g. a record not being created.
* Add a unit test, that should be failing for the expected reason. Use mocks where needed.
* Add code to make the unit test pass.
* Follow the TDD cycle as many times as needed.
* Add integration tests for implementations of repositories.
* Add code to make the integration tests pass.
* The acceptance test should be passing now.

That testing approach is the one recommended by Codely in their courses and I felt quite comfortable doing things that way.

Usually I'd have tested every object with a mix of unit and integration tests, maybe adding an acceptance test here and there, but that approach sometimes causes that the same thing is tested more than once, without really giving any extra confidence in doing so.

In any case, I always prefer to agree with the team the best approach and define what to test and how to test it in a style guide.

#### Acceptance tests

This kind of tests are testing an entire entry point in the application (Rake task in this case), from start to finish.

These are the tests that give you more confidence about the code, but at the same time are the slowest tests.

**Black box testing** is applied, so any small change in the code does not have to imply a change in the tests as well.

Besides checking a given file to import records exists, only the happy path is tested. Nothing is being done with any other possible exception that could be raised, so in other tests is tested that those exceptions are actually being raised.

Some [RSpec hooks](https://rspec.info/documentation/3.12/rspec-core/RSpec/Core/Hooks.html) are used to configure examples:

* *sidekiq_inline*: a Sidekiq job that is part of the process is immediately executed.
* *freeze_time*: the desired time object must be provided.

##### Import merchants task

Some tests check the argument received is an existing file.

Another test checks the number of merchants created is the expected one.

Maybe another expectation regarding the attributes of each merchant could be set, but I kept it simple.

##### Import orders task

Some tests check the argument received is an existing file.

Another test checks the number of orders created is the expected one.

Here I could add exactly the same comment than before for merchants.

##### Generate disbursements and monthly fees task

Checks expected disbursements and monthly fees for disbursable merchants are created based on the current time in the test and the data present in the database.

Besides, it checks the disbursed orders correctly have a reference to the associated disbursement.

The *:sidekiq_inline* hook allows that one job calls another and then another until necessary. Not the best solution, but again, time constraints.

This a quite long test, doing too much and definitely this a place with lot of room for improvement.

#### Integration tests

Focused here in repositories.

Checks every edge case that comes to mind, such as returning an empty collection, a collection with expected results, creation with and without errors, etc.

#### Unit tests

The main difference here is what it's considered a unit.

Probably most people would consider a class or a method is a unit, but in this case, following once again the teachings of Codely, the use case is the one that is considered a unit.

Injected repositories are mocked using an in memory implementation that only defines expected methods. Real job classes are injected because the test only checks they are called with expected arguments and they do nothing without the *:sidekiq_inline* hook anyway.

Checks every edge case that comes to mind, such as creation with valid attributes, exceptions raised for every invalid attribute, etc.

In addition, jobs configuration is checked to ensure the queue and other Sidekiq options are correctly defined.

#### Other details

* I embrace [WET tests](https://thoughtbot.com/blog/the-case-for-wet-tests).
* `Date.current` is used instead of `CURRENT_DATE` in queries so the time can be frozen in the date I need it to be.
* In memory repositories and factories are placed within the `spec` directory, next to the test files.
* No associations have been added in factories, so all created records are explicitly defined in every spec.

### Tasks

Import merchants and orders:

```bash
$ make db-import-data
```

As specified above, that command is calling two separated Rake tasks under the hood.

For the sake of this challenge, a task has been added to generate disbursements for all existing merchants, not only those that should be disbursed in the current day:

```bash
$ make db-disbursements-backfill
```

A cron job is scheduled to run the job that generates disbursements and monthly fees at 07:00 UTC daily. Instructions said that the process must be completed by 08:00 UTC, so I'm running the process with enough time, although it should be fast enough and the time to run could be adjusted if needed.

```bash
$ make db-disbursements-generate
```

Generate a yearly report:

```bash
$ make generate-yearly-report
```

Check a [section below](#yearly-report) about that report to see the output of that command.

### Performance

I tried to create efficient code and make all processes fast.

The execution times of certain queries improved a lot with the addition of column indexes, but sometimes making the queries simpler did the trick.

Next I'll show some examples.

#### Import orders

This is the heaviest process, as it has to import +1.3M rows from a CSV file.

Definitely, I couldn't go with a naive approach like the one for merchants (50 rows), where the whole file is loaded into memory and for each line in the file a job is enqueued to import the merchant.

For that reason, I use [SmarterCSV](https://github.com/tilo/smarter_csv) gem, that allows to load a file in chunks and for each one of those chunks it enqueues a job to import an order.

Besides, the use of `Sidekiq::Client.push_bulk` cuts down on the Redis round trip latency.

I could have used tools like [ActiveRecord-Import](https://github.com/zdennis/activerecord-import) that would allow to import records in bulk and have taken less time, but I preferred to have a job per order, especially in case of exception, where debugging would be easier.

I wanted to do it as the code was ready for production.

#### Check if only a disbursement exists in the month for a merchant

This is a query that will be executed every time a disbursement is created, so it's important that it's blazingly fast.

##### First attempt

```sql
EXPLAIN ANALYZE
SELECT EXISTS (
  SELECT 1
  FROM disbursements
  WHERE merchant_id = '9332a4b0-f457-427e-8087-63dfb5ffc719'
  AND start_date >= DATE(DATE_TRUNC('month', DATE('2022-10-14')))
  AND end_date < DATE(DATE_TRUNC('month', DATE('2022-10-14')) + INTERVAL '1 month');
);
```

###### Result with exists and no indexes

```sql
Result  (cost=178.74..178.75 rows=1 width=1) (actual time=3.043..3.044 rows=1 loops=1)
   InitPlan 1 (returns $0)
     ->  Seq Scan on disbursements  (cost=0.00..893.68 rows=5 width=0) (actual time=3.042..3.042 rows=0 loops=1)
           Filter: ((merchant_id = '9332a4b0-f457-427e-8087-63dfb5ffc719'::uuid) AND (start_date >= date(date_trunc('month'::text, ('2022-10-14'::date)::timestamp with time zone
))) AND (end_date < date((date_trunc('month'::text, ('2022-10-14'::date)::timestamp with time zone) + '1 mon'::interval))))
           Rows Removed by Filter: 11468
 Planning Time: 0.122 ms
 Execution Time: 3.060 ms
```

##### Second attempt

```sql
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM disbursements
WHERE merchant_id = '9332a4b0-f457-427e-8087-63dfb5ffc719'
AND start_date >= DATE_TRUNC('month', DATE('2022-10-14'))
AND end_date < (DATE_TRUNC('month', DATE('2022-10-14')) + INTERVAL '1 month');
```

###### Result with count and indexes

```sql
Aggregate  (cost=203.12..203.13 rows=1 width=8) (actual time=0.256..0.257 rows=1 loops=1)
   ->  Bitmap Heap Scan on disbursements  (cost=180.87..203.10 rows=6 width=0) (actual time=0.253..0.254 rows=0 loops=1)
         Recheck Cond: ((merchant_id = '9332a4b0-f457-427e-8087-63dfb5ffc719'::uuid) AND (start_date >= date_trunc('month'::text, ('2022-10-14'::date)::timestamp with time zone)
) AND (end_date < (date_trunc('month'::text, ('2022-10-14'::date)::timestamp with time zone) + '1 mon'::interval)))
         ->  BitmapAnd  (cost=180.87..180.87 rows=6 width=0) (actual time=0.251..0.252 rows=0 loops=1)
               ->  Bitmap Index Scan on disbursements_merchant_id_index  (cost=0.00..5.77 rows=198 width=0) (actual time=0.050..0.050 rows=198 loops=1)
                     Index Cond: (merchant_id = '9332a4b0-f457-427e-8087-63dfb5ffc719'::uuid)
               ->  Bitmap Index Scan on disbursements_start_date_end_date_index  (cost=0.00..174.85 rows=349 width=0) (actual time=0.192..0.192 rows=305 loops=1)
                     Index Cond: ((start_date >= date_trunc('month'::text, ('2022-10-14'::date)::timestamp with time zone)) AND (end_date < (date_trunc('month'::text, ('2022-10-
14'::date)::timestamp with time zone) + '1 mon'::interval)))
 Planning Time: 0.741 ms
 Execution Time: 0.346 ms
```

### Decisions

* Code is placed in `app/contexts`:
  * Each context include the suffix `_context`, avoiding so any possible name collision with modules.
  * Inside a context there is multiple modules.
* No explicit clean architecture has been used, although implicitly some restrictions mentioned before have been applied.
* Each database table include the name of the context as prefix, e.g. `payments_disbursements`.
* Every file include its type in the filename: `CreateDisbursementJob`, `CreateDisbursementUseCase`, `DisbursementEntity`, `DisbursementIdValueObject`, ...
* Constructor is private for aggregate roots, so `.from_primitives` factory method must be used instead.
* Value objects only include `value` attribute.
* Value objects include its own validations in the constructor thanks to the combination of `dry-struct` and `dry-types` gems.
* Use dependency injection for collaborator objects from another modules and objets from the same module that need to be mocked in tests, such as repositories in use cases or domain services.
* I'm relying on a database foreign key constraint to ensure an associated record exist.
* Use individual creation of records (merchants, orders) instead of bulk creation while importing data.
* Sometimes I create custom queries instead of relying on ActiveRecord when the query is somehow more complex.
* Except when provided, UUIDs are always generated at the application level instead of delegating that generation to the database.
* To be consistent, the ID provided in the CSV for orders is stored as `reference` and a random UUID is used as ID instead.
* The order's `reference` is unique.
* The length of disbursements' `reference` is 12 alphanumeric characters, generated randomly.
* Some columns are denormalized, such as `order_ids` in disbursements or `order_amount` in order commissions.
* For storing and doing some operations with money I use `money-rails` gem:
  * Merchants' minimum monthly fee attribute could be monetized, but seems unnecessary as it is a fixed quantity.
* The code is ready to generate disbursements for orders from the past, included in the CSV file, and for new orders:
  * Orders are disbursed exactly once, as they keep a reference to the associated disbursement, that is eventually updated after the disbursement is created.
  * Those merchants whose disbursement frequency is weekly will receive disbursements from Monday to Sunday of a given week.
* I use the term commission to refer to the quantity that is charged to a merchant after applying a fee. I based that decision on [this answer](https://www.quora.com/What-is-the-difference-between-commission-and-fees), due to not having a domain expert that could confirm the right names.
* Order commissions could be included in the order aggregate root, but I kept them as separate entities, although in some repositories I'm joining both tables to get desired data.
* Due to current requirements, monthly fees are created after the first disbursement of the month for a given merchant. That logic would need to change for sure whenever the monthly fee needs to be substracted from the disbursement amount.
* Monthly fees are not created for merchants in the same month they go live in the platform. The first one is created in their next month.
* To create a monthly fee, I'm checking if there is only one disbursement in the database for the merchant within that month. The initial approach was checking a combination of the day of month and the disbursement frequency.
* Testing:
  * Follow an outside-in TDD approach for testing.
  * The goal was having great confidence in the test suite, avoiding changes in tests as much as possible when some implementation detail changed.
  * Another goal was avoiding duplicate tests where the same functionality is tested again and again in different kind of tests.
  * Factories and in memory repositories could be placed inside the `app` directory, but as they will be used only in tests, I followed the same structure within `spec` directory.
  * No FactoryBot associations are used in factories, so every associated record is explicitly generated.
* Linter:
  * Some RuboCop cops are just disabled for certain files.
  * Although it'd be a team decision, personally I prefer to explicitly disable cops in `.rubocop.yml` file, instead of doing it inline in every file.
  * Usually I've worked with single quotes, but here I chose double quotes instead.
  * I avoid conditional modifiers at the end of the lines. If there is a condition, I prefer to see it upfront.
  * I completely avoid the use of `unless` in Ruby, whenever possible. IMHO, it adds a cognitive load in most cases.
  * I like guard clauses, although in this code you'll find very few.

### Possible improvements

* Define the approach for the *strategical design* with domain experts.
* Add error handling in certain parts as there is almost no error handling right now.
* Consider adding extra logging in certain parts of the application:
  * Add tests to check logger is called with expected arguments, if necessary.
* Consider adding a test to ensure the expected job runs every day at 07:00 UTC to create disbursements and monthly fees.
* Consider adding unique constraints to some attributes or combination of attributes:
  * merchants -> `email`
  * disbursements -> `merchant_id` + `start_date` [+ `end_date`]
  * monthly fees -> `merchant_id` + `month`
* Consider forcing referential integrity in disbursements' `order_ids` column, if possible.
* Do not rely only on database foreign key constraints to ensure associated records exist:
  * Ensure in use cases that associated objects exists before performing any action.
* Consider using some constraint at the database level if eventual consistency is not possible to update disbursed orders with the corresponding disbursement ID.
* Validate the input CSV files provided to Rake tasks and add tests for that.
* Use a Sidekiq PRO batch for processing orders.
* Setup Sidekiq Web if necessary:
  * Quite useful having a UI with information about queues, failing jobs, etc.
* Consider including in `shared` directory inside every context those value objects that could be reused, such as merchant ID, order ID or disbursement ID.
* Consider adding domain events to remove some coupling between modules.
* Consider adding pagination to method `.all` for order repository, if necessary.
* Consider including order commissions as part of the order aggregate root:
  * Both records could be created within a transaction, only if strictly necessary.
* Consider tackling certain cyclomatic complexity ignored in some files, where RuboCop was silenced.
* Avoid duplication in every `#create` method in repositories.
* Consider checking specific attributes of created objects in acceptance tests instead of just checking the total number of records created.
* Add some kind of monitoring tool, such as Kibana or Datadog.
* Add some kind of CI/CD pipeline, such as GitHub Actions, GitLab or Jenkins.
* Configure container to run with a non-root user
* Remove unnecessary files from version control.

## Yearly report

As requested in the instructions provided, the yearly report is included here:

| Year  | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee) |
| :---: | :---------------------: | :---------------------------: | :------------------: | :-------------------------------------------------------: | :------------------------------------------------------: |
| 2022  |          1551           |        39,025,757.05 €        |     348,353.16 €     |                            31                             |                         562.83 €                         |
| 2023  |          10357          |       188,511,100.86 €        |    1,701,069.41 €    |                            104                            |                        1,735.65 €                        |
