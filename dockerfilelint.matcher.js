exports.matcher = async () => {
  const result = require(`${process.env.ATOMIST_OUTPUT_DIR}/dockerfilelint.json`);
  
  const check = {
      name: "dockerfilelint",
      report: "error",
      summary: `dockerfilelint found ${result.totalIssues} ${result.totalIssues === 1 ? "issue" : "issues"}`,
      severity: "action_required",
      annotations: [],
  };
  
  const mapSeverity = (category) => {
      switch (category) {
          case "Clarity":
          case "Optimization":
              return "notice";
          case "Possible Bug":
          default:
              return "warning";
      }
  };
  
  result.files.forEach(f => {
      f.issues.forEach(i => {
          check.annotations.push({
              path: f.file,
              message: i.description,
              line: +i.line,
              column: 1,
              title: i.title,
              severity: mapSeverity(i.category),
          });
      });
  });

  return check;
};
