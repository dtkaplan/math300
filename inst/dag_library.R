#' A library of DAGS. These are available in data/.
#'
#'
#'
library(math300)


dag00 <- dag_make(
  x ~ exo(2) + 5,
  y ~ exo(1) - 7
)

dag01 <- dag_make(
  x ~ exo(),
  y ~ 1.5*x + 4.0 + exo()
)


dag02 <- dag_make(
  x ~ exo(),
  a ~ exo(),
  y ~ 3*x - 1.5*a + 5 +  exo()
)

dag03 <- dag_make(
  g ~ exo(),
  x ~ 1.0*g + exo(),
  y ~ 1.0*g + exo()
)

dag04 <- dag_make(
  a ~ exo(),
  b ~ exo(),
  c ~ exo(),
  d ~ a + b + c + exo()
)

dag05 <- dag_make(
  a ~ exo(),
  b ~ a + exo(),
  c ~ b + exo(),
  d ~ c + exo()
)

dag06 <- dag_make(
  a ~ exo(),
  b ~ a + exo(),
  c ~ b + exo(),
  d ~ c + a + exo()
)

dag07 <- dag_make(
  a ~ exo(),
  b ~ exo() - a,
  c ~ a - b + exo(),
  d ~ exo()
)

dag08 <- dag_make(
  c ~ exo(),
  x ~ c + exo(),
  y ~ x + c + 3 + exo()
)

dag09 <- dag_make(
  a ~ exo(),
  b ~ exo(),
  c ~ binom(2*a+ 3*b)
)


# a case-control style data source. There are roughly
# even numbers of 0s and 1s. Only a, b, c have an impact on y
dag10 <- dag_make(
  a ~ exo(),
  b ~ exo(),
  c ~ exo(),
  d ~ exo(),
  e ~ exo(),
  f ~ 2*binom() - 1,
  y ~ binom(2*a - 3*b + c - 1.5*d + 1*e + 0.5*f)
)

dag11 <- dag_make(
  x ~ exo(),
  y ~ exo(),
  g ~ x + y + exo()
)

dag12 <- dag_make(
  x ~ exo(),
  y ~ exo(),
  h ~ x + y,
  g ~- h + exo()
)

dag_prob_21.1 <- dag_make(
  x ~ exo(1),
  y ~ x + exo(2)
)

dag_school1 <- dag_make(
  expenditure ~ unif(7000, 18000),
  participation ~ unif(1,100),
  outcome ~ 1100 + 0.01*expenditure - 4*participation + exo(50)
)

dag_school2 <- dag_make(
  culture ~ unif(-1, 1),
  expenditure ~ 12000 + 4000 * culture + exo(1000),
  participation ~ (50 + 30 * culture + exo(15)) %>%
    pmax(0) %>% pmin(100),
  outcome ~ 1100 + 0.01*expenditure - 4*participation + exo(50)
)

dag_vaccine <- dag_make(
  .h ~ exo(1),
  .v ~ 0.2 + 2* .h + exo(.25),
  .f ~ -0.5 - 0.5 * binom(.v) - 1*.h,
  .s ~ 2 - 0.2*binom(.f) + 0.4*(.h + 0.5),
  died ~ binom(.s, labels=c("yes", "no")),
  vaccinated ~ binom(.v, labels=c("none", "yes")),
  health ~ binom(.h, labels=c("poor", "good")),
  flu ~ binom(.f)
)

dag_satgpa <- dag_make(
  sat ~ unif(min=400, max=1600),
  gpa ~ 4*(pnorm(((sat-1000)/300 + exo(2.0))/4))^0.6
)

dag_flights <- dag_make(
  ready ~ each(10),
  abortAM ~ count_flips(ready, .06),
  AM ~ ready - abortAM,
  brokeAM  ~ count_flips(AM, 0.12),
  PM ~ AM - brokeAM + count_flips(abortAM, 0.67) + count_flips(brokeAM, .4),
  abortPM ~ count_flips(PM, .06),
  brokePM ~ count_flips(PM - abortPM, .12)
)

dag_medical_observations <- dag_make(
  .sex ~ binom(x=exo(), labels=c("F", "M")),
  .cond ~ exo(),
  treatment ~ binom(1*(.sex=="F")- .cond, labels=c("none", "treat")),
  outcome ~ -0.5*(treatment=="treat") - .cond + 1.5*(.sex=="F") + exo()
)

list_of_dags <- c(
  lapply(as.list(ls(pattern="dag[_0-9]")), as.name),
  file = "data/daglib.rda")

do.call(save, list_of_dags)

