/*
 * Copyright © 2020 Atomist, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

exports.matcher = async () => {
  const result = require(`${process.env.ATOMIST_OUTPUT_DIR}/dockerfilelint.json`);

  const check = {
      name: "dockerfilelint",
      report: "always",
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
