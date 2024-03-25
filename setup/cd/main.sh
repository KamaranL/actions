#!/bin/bash

echo ::group::Setting up CD...

echo - Getting recently pushed tag
PR_NUM="$(echo -e "$WFR_REF" | grep -oE '[0-9]{1,}')"
BASE_REF="$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)"
CI_TAG="v$(curl -s -H "Authorization: Token $GH_TOKEN" \
    -L https://raw.githubusercontent.com/$GITHUB_REPOSITORY/${BASE_REF:-HEAD}/VERSION.txt)"

echo "- Switching ref to tags/$CI_TAG"
git checkout tags/"$CI_TAG"

echo "CI_TAG=$CI_TAG" >>"$GITHUB_ENV"
echo "# $CI_TAG :arrow_right:" >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
