# Starting from Python 3 base image
FROM python:3

# Set the WORKDIR to /app so all following commands run in /app
WORKDIR /app

# copy project to workdir
COPY . .

# Install requirements and dev requirements through pip. Those should include
# nostest, pytest or any other test framework you use
# RUN pip3 install pipenv && pipenv install

ENTRYPOINT ["~/app/.github/actions/build_and_test/entrypoint.sh"]
